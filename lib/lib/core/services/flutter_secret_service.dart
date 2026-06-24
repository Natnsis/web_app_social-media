import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FlutterSecureService {
  static const FlutterSecureStorage _flutterSecureStorage =
      FlutterSecureStorage();

  static final String _tokenKey = 'accessToken';
  static final String _refreshTokenKey = 'refreshToken';
  static const String _savedPasswordKey = 'saved_password';

  static Future<void> setToken(String token) async {
    await _flutterSecureStorage.write(key: _tokenKey, value: token);
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    await _flutterSecureStorage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  static Future<String?> getToken() async {
    return await _flutterSecureStorage.read(key: _tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _flutterSecureStorage.read(key: _refreshTokenKey);
  }

  static Future<void> savePassword(String password) async {
    await _flutterSecureStorage.write(key: _savedPasswordKey, value: password);
  }

  static Future<String?> getSavedPassword() async {
    return _flutterSecureStorage.read(key: _savedPasswordKey);
  }

  static Future<void> deleteSavedPassword() async {
    await _flutterSecureStorage.delete(key: _savedPasswordKey);
  }

  static Future<void> deleteTokens() async {
    await _flutterSecureStorage.delete(key: _tokenKey);
    await _flutterSecureStorage.delete(key: _refreshTokenKey);
  }

  static Future<void> clearCache() async {
    await _flutterSecureStorage.deleteAll();
  }
}
