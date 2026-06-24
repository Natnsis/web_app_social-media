import 'dart:async';

import 'package:faithconnect/core/constants/socket_namespace.dart';
import 'package:faithconnect/core/services/socket/socket_services.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class UserLocationSocketService {
  final SocketService _socketService;
  io.Socket? _socket;
  StreamSubscription<Position>? _positionSubscription;
  static const _tag = 'UserLocationSocket';

  UserLocationSocketService({required SocketService socketService})
      : _socketService = socketService;

  /// Starts streaming location data. Connects to the socket if not already connected.
  /// Requests location permissions if needed.
  Future<void> startStreaming() async {
    // 1. Check and request permissions
    if (!await Geolocator.isLocationServiceEnabled()) {
      FaithLogger.w(_tag, 'Location services are disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      FaithLogger.w(_tag, 'Location permission denied.');
      return;
    }

    // 2. Connect the socket
    _socket ??= _socketService.connect(SocketNamespace.userLocation);

    // 3. Start position stream if not already running
    if (_positionSubscription == null) {
      FaithLogger.d(_tag, 'Starting GPS coordinate stream.');
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Only update if moved 10 meters
        ),
      ).listen((Position position) {
        FaithLogger.d(_tag, 'Emitting location update: \${position.latitude}, \${position.longitude}');
        _socket?.emit('updateLocation', {
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      });
    }
  }

  /// Stops streaming location data, but keeps the socket connected.
  void stopStreaming() {
    if (_positionSubscription != null) {
      FaithLogger.d(_tag, 'Stopping GPS coordinate stream.');
      _positionSubscription?.cancel();
      _positionSubscription = null;
    }
  }

  /// Fully disconnects the socket and cleans up the stream.
  void disconnect() {
    stopStreaming();
    if (_socket != null) {
      FaithLogger.d(_tag, 'Disconnecting from User Location socket.');
      _socketService.disconnect(SocketNamespace.userLocation);
      _socket = null;
    }
  }
}
