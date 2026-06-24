class DeviceRegistrationDto {
  final String deviceId;
  final String fcmToken;
  final String platform;
  final String appVersion;

  DeviceRegistrationDto({
    required this.deviceId,
    required this.fcmToken,
    required this.platform,
    required this.appVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'fcmToken': fcmToken,
      'platform': platform,
      'appVersion': appVersion,
    };
  }
}
