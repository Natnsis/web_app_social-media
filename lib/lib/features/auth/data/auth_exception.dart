enum AuthErrorCode {
  accountNotVerified,
  cancelled,
  generic,
}

class AuthException implements Exception {
  final String message;
  final AuthErrorCode code;
  final String? phoneNumber;

  const AuthException(
    this.message, {
    this.code = AuthErrorCode.generic,
    this.phoneNumber,
  });

  bool get isAccountNotVerified => code == AuthErrorCode.accountNotVerified;

  bool get isCancelled => code == AuthErrorCode.cancelled;

  @override
  String toString() => message;
}
