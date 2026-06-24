import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested();
}

final class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed();
}

final class NotificationsFilterChanged extends NotificationsEvent {
  final NotificationFilter filter;

  const NotificationsFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class NotificationMarkedRead extends NotificationsEvent {
  final String notificationId;

  const NotificationMarkedRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

final class NotificationsMarkAllRead extends NotificationsEvent {
  const NotificationsMarkAllRead();
}

final class NotificationsUnreadCountRequested extends NotificationsEvent {
  const NotificationsUnreadCountRequested();
}

final class NotificationPreferencesRequested extends NotificationsEvent {
  const NotificationPreferencesRequested();
}

final class NotificationPreferencesUpdated extends NotificationsEvent {
  final bool? emailNotifications;
  final bool? pushNotifications;
  final bool? smsNotifications;

  const NotificationPreferencesUpdated({
    this.emailNotifications,
    this.pushNotifications,
    this.smsNotifications,
  });

  @override
  List<Object?> get props => [emailNotifications, pushNotifications, smsNotifications];
}
