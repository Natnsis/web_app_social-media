import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/auth_token_provider.dart';
import 'package:geolocator/geolocator.dart';

/// Saves the device location via `PATCH /v1/users/me/location` so
/// `GET /v1/churches/nearby` can use the authenticated user's coordinates.
class UserLocationSyncService {
  UserLocationSyncService({required Dio dio}) : _dio = dio;

  final Dio _dio;
  DateTime? _lastSyncedAt;

  static const _minSyncInterval = Duration(minutes: 5);

  /// Best-effort sync before nearby search (requires JWT + location permission).
  Future<void> ensureSavedForNearby() async {
    final token = await AuthTokenProvider.getAccessToken();
    if (token == null || token.isEmpty) return;

    final last = _lastSyncedAt;
    if (last != null && DateTime.now().difference(last) < _minSyncInterval) {
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      await _dio.patch<dynamic>(
        UsersApiEndpoint.meLocation,
        data: <String, dynamic>{
          'latitude': position.latitude,
          'longitude': position.longitude,
          'locationSharingEnabled': true,
        },
      );

      _lastSyncedAt = DateTime.now();
    } on DioException {
      // Nearby call may still succeed if location was saved earlier.
    } catch (_) {}
  }
}
