import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/notifications/data/dto/device_registration_dto.dart';
import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';
import 'package:faithconnect/features/notifications/domain/entities/notification_preferences.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> fetchNotifications();

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, NotificationPreferences>> getPreferences();

  Future<Either<Failure, void>> updatePreferences(NotificationPreferences preferences);

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> registerDevice(DeviceRegistrationDto dto);

  Future<Either<Failure, void>> unregisterDevice(String deviceId);
}
