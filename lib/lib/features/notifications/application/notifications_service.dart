import 'dart:io';



import 'package:dartz/dartz.dart';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:faithconnect/core/error/failures.dart';

import 'package:faithconnect/core/services/notification_service/notification_service.dart';

import 'package:faithconnect/core/services/push/push_notification_payload.dart';

import 'package:faithconnect/core/services/push/push_notification_sync.dart';

import 'package:faithconnect/core/services/shared_prefs_Service.dart';

import 'package:faithconnect/core/utils/faith_logger.dart';

import 'package:faithconnect/features/notifications/data/dto/device_registration_dto.dart';

import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';

import 'package:faithconnect/features/notifications/domain/entities/notification_preferences.dart';

import 'package:faithconnect/features/notifications/domain/repositories/notifications_repository.dart';

import 'package:package_info_plus/package_info_plus.dart';



class NotificationsService {

  final NotificationsRepository _repository;

  final NotificationService _pushService;



  NotificationsService(

    this._repository, {

    NotificationService? pushService,

  }) : _pushService = pushService ?? NotificationService();



  Future<Either<Failure, List<AppNotification>>> fetchNotifications() =>

      _repository.fetchNotifications();



  Future<Either<Failure, int>> getUnreadCount() =>

      _repository.getUnreadCount();



  Future<Either<Failure, NotificationPreferences>> getPreferences() =>

      _repository.getPreferences();



  Future<Either<Failure, void>> updatePreferences(

    NotificationPreferences preferences,

  ) =>

      _repository.updatePreferences(preferences);



  Future<Either<Failure, void>> markAsRead(String notificationId) =>

      _repository.markAsRead(notificationId);



  Future<Either<Failure, void>> markAllAsRead() => _repository.markAllAsRead();



  /// Initializes FCM listeners, local notification display, and device registration.

  Future<void> initializePush({

    void Function(PushNotificationPayload payload)? onInboundPush,

  }) async {

    PushNotificationSync.instance.onInboundPush = onInboundPush;



    await _pushService.initialize(

      onTokenRefresh: (_) => registerDeviceToken(),

    );



    if (await SharedPrefsService.isLoggedIn()) {

      await registerDeviceToken();

    }

  }



  Future<String?> getFcmToken() => _pushService.getFCMToken();



  Stream<String> get onFcmTokenRefresh => _pushService.onTokenRefresh;



  Future<Either<Failure, void>> registerDeviceToken([String? tokenOverride]) async {

    try {

      if (!await SharedPrefsService.isLoggedIn()) {

        return const Left(AuthFailure(message: 'Not authenticated'));

      }



      final fcmToken = tokenOverride ?? await _pushService.getFCMToken();

      if (fcmToken == null) {

        return const Left(ServerFailure(message: 'No FCM token'));

      }



      final deviceInfo = DeviceInfoPlugin();

      var deviceId = '';

      if (Platform.isAndroid) {

        final info = await deviceInfo.androidInfo;

        deviceId = info.id;

      } else if (Platform.isIOS) {

        final info = await deviceInfo.iosInfo;

        deviceId = info.identifierForVendor ?? '';

      }



      final packageInfo = await PackageInfo.fromPlatform();

      final dto = DeviceRegistrationDto(

        deviceId: deviceId,

        fcmToken: fcmToken,

        platform: Platform.isAndroid ? 'ANDROID' : 'IOS',

        appVersion: packageInfo.version,

      );



      return await _repository.registerDevice(dto);

    } catch (e) {

      FaithLogger.e('NotificationsService', 'Failed to register device token: $e');

      return Left(ServerFailure(message: e.toString()));

    }

  }



  Future<Either<Failure, void>> unregisterDeviceToken() async {

    try {

      if (!await SharedPrefsService.isLoggedIn()) {

        return const Left(AuthFailure(message: 'Not authenticated'));

      }



      final deviceInfo = DeviceInfoPlugin();

      var deviceId = '';



      if (Platform.isAndroid) {

        final info = await deviceInfo.androidInfo;

        deviceId = info.id;

      } else if (Platform.isIOS) {

        final info = await deviceInfo.iosInfo;

        deviceId = info.identifierForVendor ?? '';

      }



      if (deviceId.isEmpty) {

        return const Left(ServerFailure(message: 'Could not obtain device ID'));

      }



      return await _repository.unregisterDevice(deviceId);

    } catch (e) {

      FaithLogger.e('NotificationsService', 'Failed to unregister device: $e');

      return Left(ServerFailure(message: e.toString()));

    }

  }

}
