import 'dart:convert';

import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/core/network/auth_token_provider.dart';
import 'package:faithconnect/core/services/flutter_secret_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SharedPrefsService {
  static const String _isLoggedInKey = 'is_logged_in';

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _verificationIdKey = 'verification_id';
  static const String _userIdKey = 'user_id';
  static const String _userKey = 'user';
  static const String _firstTimerKey = 'first_timer';
  static const String _driverIdKey = 'driver_id';
  static const String _vendorIdKey = 'vendor_id';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _pendingVerificationPhoneKey =
      'pending_verification_phone';
  static const String _homeShellAccountModeKey = 'home_shell_account_mode';

  /// Stored values for church vs member account view (`setAccountViewMode`).
  static const String accountViewModeChurch = 'church';
  static const String accountViewModeUser = 'user';

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> setFirstTimer(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimerKey, value);
  }

  static Future<bool> isFirstTimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimerKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<void> saveDriverId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverIdKey, value);
  }

  static Future<String?> getDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_driverIdKey);
  }
  
  static Future<void> saveVendorId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vendorIdKey, value);
  }

  static Future<String?> getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vendorIdKey);
  }

  static Future<void> saveVerificationId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationIdKey, value);
  }

  static Future<String?> getVerificationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_verificationIdKey);
  }

  static Future<void> saveUserId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, value);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Persists JWT access token (migrates legacy secure storage on first read).
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await FlutterSecureService.setToken(token);
    AuthTokenProvider.setAccessToken(token);
  }

  /// Reads access token from prefs, falling back to secure storage once.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(_accessTokenKey);
    if (token == null || token.isEmpty) {
      token = await FlutterSecureService.getToken();
      if (token != null && token.isNotEmpty) {
        await prefs.setString(_accessTokenKey, token);
        AuthTokenProvider.setAccessToken(token);
      }
    }
    if (token != null && token.isNotEmpty) {
      AuthTokenProvider.setAccessToken(token);
    }
    return token;
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
    await FlutterSecureService.setRefreshToken(token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(_refreshTokenKey);
    if (token == null || token.isEmpty) {
      token = await FlutterSecureService.getRefreshToken();
      if (token != null && token.isNotEmpty) {
        await prefs.setString(_refreshTokenKey, token);
      }
    }
    return token;
  }

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
  }

  static Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.trim().isNotEmpty;
  }

  static Future<void> clearAuthTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await FlutterSecureService.deleteTokens();
    AuthTokenProvider.clear();
  }

  // ---------- First‑launch helpers ----------
  static const String _firstLaunchKey = 'first_launch_done';

  /// Returns true if this is the very first app launch (i.e. onboarding not shown yet).
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstLaunchKey) ?? false);
  }

  /// Marks that onboarding has been completed so it won't be shown again.
  static Future<void> setFirstLaunchDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, true);
  }

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  static Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<void> setPendingVerificationPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingVerificationPhoneKey, phone);
  }

  static Future<String?> getPendingVerificationPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingVerificationPhoneKey);
  }

  static Future<void> clearPendingVerificationPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingVerificationPhoneKey);
  }

  static Future<void> saveLoginCredentials({
    required String email,
    required bool rememberMe,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await prefs.setString(_savedEmailKey, email);
    } else {
      await prefs.remove(_savedEmailKey);
    }
  }

  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedEmailKey);
  }

  /// Removes legacy demo login values (e.g. pre-filled test accounts).
  static Future<void> clearLegacyDemoLoginCredentials() async {
    const legacyEmails = {
      'yared@gmail.com',
      'user@example.com',
    };
    const legacyPasswords = {'123456', 'password123'};

    final email = (await getSavedEmail())?.trim().toLowerCase();
    final password = await FlutterSecureService.getSavedPassword();

    final isLegacyEmail = email != null && legacyEmails.contains(email);
    final isLegacyPassword =
        password != null && legacyPasswords.contains(password);

    if (isLegacyEmail || isLegacyPassword) {
      await clearSavedLoginCredentials();
    }
  }

  /// Clears remember-me email/password (does not log the user out of the app).
  static Future<void> clearSavedLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedEmailKey);
    await prefs.setBool(_rememberMeKey, false);
    await FlutterSecureService.deleteSavedPassword();
  }

  static Future<void> setHomeShellAccountMode(String mode) async {
    await setAccountViewMode(mode);
  }

  static Future<String?> getHomeShellAccountMode() async {
    return getAccountViewMode();
  }

  /// Persists church (`church`) or member (`user`) account view for shell + settings.
  static Future<void> setAccountViewMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_homeShellAccountModeKey, mode);
  }

  static Future<String?> getAccountViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_homeShellAccountModeKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_pendingVerificationPhoneKey);
    await clearAuthTokens();
  }
}
