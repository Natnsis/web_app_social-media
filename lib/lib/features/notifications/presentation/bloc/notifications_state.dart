import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';
import 'package:faithconnect/features/notifications/domain/entities/notification_preferences.dart';

enum NotificationsStatus { initial, loading, loaded, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final NotificationFilter filter;
  final int globalUnreadCount;
  final NotificationPreferences? preferences;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.filter = NotificationFilter.all,
    this.globalUnreadCount = 0,
    this.preferences,
    this.errorMessage,
  });

  List<AppNotification> get visibleNotifications {
    if (filter == NotificationFilter.unread) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    NotificationFilter? filter,
    int? globalUnreadCount,
    NotificationPreferences? preferences,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      filter: filter ?? this.filter,
      globalUnreadCount: globalUnreadCount ?? this.globalUnreadCount,
      preferences: preferences ?? this.preferences,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        filter,
        globalUnreadCount,
        preferences,
        errorMessage,
      ];
}
