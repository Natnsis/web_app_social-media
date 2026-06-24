/// Request body for `POST /v1/auth/login/google`.
///
/// ```json
/// { "idToken": "<google-id-token>" }
/// ```
class GoogleAuthDto {  final String idToken;

  const GoogleAuthDto({required this.idToken});

  Map<String, dynamic> toJson() => {'idToken': idToken};
}
