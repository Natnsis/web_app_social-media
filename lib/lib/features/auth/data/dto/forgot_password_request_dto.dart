/// Request body for `POST /v1/auth/password/forgot`.
class ForgotPasswordRequestDto {
  final String phoneNumber;

  const ForgotPasswordRequestDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}
