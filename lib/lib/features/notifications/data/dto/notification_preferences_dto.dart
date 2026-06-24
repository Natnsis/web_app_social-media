import 'package:faithconnect/features/notifications/domain/entities/notification_preferences.dart';

class NotificationPreferencesDto {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  NotificationPreferencesDto({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.smsNotifications,
  });

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDto(
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
    };
  }

  NotificationPreferences toEntity() {
    return NotificationPreferences(
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
      smsNotifications: smsNotifications,
    );
  }

  factory NotificationPreferencesDto.fromEntity(NotificationPreferences entity) {
    return NotificationPreferencesDto(
      emailNotifications: entity.emailNotifications,
      pushNotifications: entity.pushNotifications,
      smsNotifications: entity.smsNotifications,
    );
  }
}
