import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  const NotificationPreferences({
    required this.emailNotifications,
    required this.pushNotifications,
    required this.smsNotifications,
  });

  NotificationPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
  }) {
    return NotificationPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
    );
  }

  @override
  List<Object?> get props => [emailNotifications, pushNotifications, smsNotifications];
}
