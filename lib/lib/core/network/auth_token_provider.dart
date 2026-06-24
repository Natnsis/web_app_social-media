import 'package:faithconnect/core/services/shared_prefs_Service.dart';

/// In-memory access token used by [AuthInterceptor] (kept in sync with prefs).
abstract final class AuthTokenProvider {
  AuthTokenProvider._();

  static String? _cachedAccessToken;

  static Future<String?> getAccessToken() async {
    final cached = _cachedAccessToken;
    if (cached != null && cached.isNotEmpty) return cached;

    final stored = await SharedPrefsService.getAccessToken();
    if (stored != null && stored.isNotEmpty) {
      _cachedAccessToken = stored;
    }
    return stored;
  }

  static void setAccessToken(String? token) {
    _cachedAccessToken =
        token != null && token.trim().isNotEmpty ? token.trim() : null;
  }

  static void clear() {
    _cachedAccessToken = null;
  }
}
