import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectionChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker.createInstance();

  @override
  Future<bool> get isConnected {
    if (kIsWeb) {
      return _connectivity.checkConnectivity().then((result) => !result.contains(ConnectivityResult.none));
    }
    return _connectionChecker.hasConnection;
  }

  @override
  Stream<bool> get onConnectionChanged {
    if (kIsWeb) {
      return _connectivity.onConnectivityChanged.map((result) => !result.contains(ConnectivityResult.none));
    }
    return _connectionChecker.onStatusChange.map((status) => status == InternetConnectionStatus.connected);
  }
}
