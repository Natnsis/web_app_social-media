import 'package:faithconnect/core/services/shared_prefs_Service.dart';

/// Clears local session and notifies the app (e.g. navigate to login).
class AuthSessionCoordinator {
  Future<void> Function()? onSessionExpired;

  bool _handling = false;

  Future<void> handleSessionExpired() async {
    if (_handling) return;
    _handling = true;
    try {
      await SharedPrefsService.logout();
      final handler = onSessionExpired;
      if (handler != null) {
        await handler();
      }
    } finally {
      _handling = false;
    }
  }
}
