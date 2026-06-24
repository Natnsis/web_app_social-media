/// Google SDK result passed to [AuthRemoteDataSource.loginWithGoogle].
class GoogleIdTokenDto {
  final String idToken;
  final String email;

  const GoogleIdTokenDto({
    required this.idToken,
    required this.email,
  });
}
