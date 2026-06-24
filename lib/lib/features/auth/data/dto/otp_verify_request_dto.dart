/// Request body for `POST /v1/auth/otp/verify`.
class OtpVerifyRequestDto {
  final String phoneNumber;
  final String otp;

  const OtpVerifyRequestDto({
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'otp': otp,
      };
}
