/// Request body for `POST /v1/auth/register`.
class RegisterRequestDto {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterRequestDto({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      };
}
