import 'package:faithconnect/core/models/app_user_role.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/features/auth/data/models/user_model.dart';

/// Parsed auth payload from register/login responses.
class AuthSessionPayload {
  final UserModel user;
  final String? accessToken;
  final String? refreshToken;

  const AuthSessionPayload({
    required this.user,
    this.accessToken,
    this.refreshToken,
  });

  bool get hasAccessToken =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  Future<void> persistTokens() async {
    if (!hasAccessToken) return;
    await SharedPrefsService.saveTokens(
      accessToken: accessToken!,
      refreshToken: refreshToken,
    );
  }

  /// Token pair from login/register/refresh responses.
  static ({String? accessToken, String? refreshToken}) parseTokensFromResponse(
    dynamic body,
  ) {
    final root = _asMap(body);
    final data = _asMap(root?['data']) ?? root ?? {};
    return (
      accessToken: _readToken(data, 'accessToken', 'access_token', 'token'),
      refreshToken: _readToken(data, 'refreshToken', 'refresh_token'),
    );
  }

  static AuthSessionPayload fromResponse(
    dynamic body, {
    RegisterFallbackUser? registerFallback,
    LoginFallbackUser? loginFallback,
  }) {
    assert(
      registerFallback != null || loginFallback != null,
      'Provide registerFallback or loginFallback',
    );

    final root = _asMap(body);
    final data = _asMap(root?['data']) ?? root ?? {};
    final roles = parseRolesFromResponse(body);

    final userMap = _asMap(data['user']) ??
        _asMap(data['profile']) ??
        (data.containsKey('id') || data.containsKey('email') ? data : null);

    final user = userMap != null
        ? UserModel.fromJson(userMap, roles: roles)
        : UserModel(
            id: data['id']?.toString() ?? data['userId']?.toString() ?? '',
            email: registerFallback?.email ??
                _emailFromLoginIdentifier(loginFallback!.emailOrPhone),
            name: registerFallback?.fullName ?? '',
            phone: registerFallback?.phoneNumber ??
                _phoneFromLoginIdentifier(loginFallback?.emailOrPhone),
            roles: roles,
          );

    return AuthSessionPayload(
      user: user,
      accessToken: _readToken(data, 'accessToken', 'access_token', 'token'),
      refreshToken:
          _readToken(data, 'refreshToken', 'refresh_token'),
    );
  }

  static String? _readToken(
    Map<String, dynamic> data,
    String a,
    String b, [
    String? c,
  ]) {
    for (final key in [a, b, ?c]) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _emailFromLoginIdentifier(String identifier) {
    final trimmed = identifier.trim();
    return trimmed.contains('@') ? trimmed.toLowerCase() : '';
  }

  static String? _phoneFromLoginIdentifier(String? identifier) {
    if (identifier == null) return null;
    final trimmed = identifier.trim();
    return trimmed.contains('@') ? null : trimmed;
  }

  static List<String> parseRolesFromResponse(dynamic body) {
    final root = _asMap(body);
    final data = _asMap(root?['data']) ?? root;
    if (data == null) return const [];

    final roles = <String>{...AppUserRole.collectFromMap(data)};

    final user = _asMap(data['user']);
    if (user != null) {
      roles.addAll(AppUserRole.collectFromMap(user));
    }

    return roles.toList(growable: false);
  }

  /// True when the API indicates the account still needs phone OTP verification.
  static bool requiresPhoneVerification(dynamic body) {
    final root = _asMap(body);
    final data = _asMap(root?['data']) ?? root;
    if (data == null) return false;

    for (final key in [
      'requiresVerification',
      'requiresPhoneVerification',
      'phoneVerificationRequired',
    ]) {
      if (data[key] == true) return true;
    }

    for (final key in ['phoneVerified', 'isPhoneVerified', 'verified']) {
      if (data[key] == false) return true;
    }

    final user = _asMap(data['user']);
    if (user != null) {
      for (final key in ['phoneVerified', 'isPhoneVerified', 'verified']) {
        if (user[key] == false) return true;
      }
    }

    return false;
  }
}

class LoginFallbackUser {
  final String emailOrPhone;

  const LoginFallbackUser({required this.emailOrPhone});
}

class RegisterFallbackUser {
  final String fullName;
  final String email;
  final String phoneNumber;

  const RegisterFallbackUser({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });
}
