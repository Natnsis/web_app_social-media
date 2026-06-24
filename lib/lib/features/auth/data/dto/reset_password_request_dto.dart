/// Request body for `POST /v1/auth/password/reset`.
class ResetPasswordRequestDto {
  final String phoneNumber;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequestDto({
    required this.phoneNumber,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
}
