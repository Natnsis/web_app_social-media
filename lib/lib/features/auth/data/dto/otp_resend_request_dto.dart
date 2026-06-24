/// Request body for `POST /v1/auth/otp/resend`.
class OtpResendRequestDto {
  final String phoneNumber;

  const OtpResendRequestDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {'phoneNumber': phoneNumber};
}
