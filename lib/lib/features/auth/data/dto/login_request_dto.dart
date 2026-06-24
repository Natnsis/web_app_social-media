/// Request body for `POST /v1/auth/login`.
class LoginRequestDto {
  final String emailOrPhone;
  final String password;

  const LoginRequestDto({
    required this.emailOrPhone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'emailOrPhone': emailOrPhone,
        'password': password,
      };
}
