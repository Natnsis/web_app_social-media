import 'package:dartz/dartz.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:faithconnect/features/notifications/data/dto/device_registration_dto.dart';
import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';
import 'package:faithconnect/features/notifications/domain/entities/notification_preferences.dart';
import 'package:faithconnect/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AppNotification>>> fetchNotifications() async {
    try {
      return Right(await remoteDataSource.fetchNotifications());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      return Right(await remoteDataSource.getUnreadCount());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() async {
    try {
      return Right(await remoteDataSource.getPreferences());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(NotificationPreferences preferences) async {
    try {
      await remoteDataSource.updatePreferences(preferences);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerDevice(DeviceRegistrationDto dto) async {
    try {
      await remoteDataSource.registerDevice(dto);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterDevice(String deviceId) async {
    try {
      await remoteDataSource.unregisterDevice(deviceId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
