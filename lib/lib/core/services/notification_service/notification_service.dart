import 'dart:async';
import 'dart:convert';

import 'package:faithconnect/core/routes/routes.dart';
import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:faithconnect/core/services/push/push_notification_payload.dart';
import 'package:faithconnect/core/services/push/push_notification_sync.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  static NotificationService? _instance;

  factory NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) {
    _instance ??= NotificationService._internal(
      messaging ?? FirebaseMessaging.instance,
      localNotifications ?? FlutterLocalNotificationsPlugin(),
    );
    return _instance!;
  }

  NotificationService._internal(
    this._firebaseMessaging,
    this._flutterLocalNotificationsPlugin,
  );

  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  bool _isInitialized = false;
  Future<void> Function(String token)? _onTokenRefresh;

  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  Future<void> initialize({
    Future<void> Function(String token)? onTokenRefresh,
  }) async {
    if (_isInitialized) return;
    _onTokenRefresh = onTokenRefresh;

    StructuredFcmLog.log(
      step: 'service_init',
      message: 'NotificationService initializing',
    );

    try {
      await _requestPermissions();
      await getFCMToken();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          StructuredFcmLog.log(
            step: 'local_notification_tap',
            message: 'Local notification tapped',
            details: {
              if (details.id != null) 'notification_id': details.id,
              if (details.payload != null) 'payload': details.payload,
            },
          );
          _navigateToNotifications();
        },
      );

      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _logRemoteMessage('message_cold_start', initialMessage);
        _handleMessage(initialMessage);
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        StructuredFcmLog.log(
          step: 'token_refresh',
          message:
              'FCM token refreshed: ${StructuredFcmLog.tokenPreview(newToken)}',
          details: StructuredFcmLog.tokenDetails(newToken),
        );
        await _onTokenRefresh?.call(newToken);
      });

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _isInitialized = true;
      StructuredFcmLog.log(
        step: 'service_ready',
        message: 'NotificationService initialized',
      );
    } catch (e, st) {
      StructuredFcmLog.log(
        step: 'service_init_failed',
        message: 'NotificationService init failed: $e',
        level: FcmLogLevel.error,
        details: {
          'error': e.toString(),
          'stack_trace': st.toString(),
        },
      );
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    final status = settings.authorizationStatus;
    StructuredFcmLog.log(
      step: 'permission',
      message: 'Notification permission: ${status.name}',
      level: status == AuthorizationStatus.denied
          ? FcmLogLevel.warning
          : FcmLogLevel.info,
      details: {'authorization_status': status.name},
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logRemoteMessage('message_foreground', message);

    if (_isNewLoginDetectedAlert(message)) {
      StructuredFcmLog.log(
        step: 'message_foreground_suppressed',
        message: 'Skipped UI for new-login-detected security push',
        details: StructuredFcmLog.remoteMessageDetails(message.data),
      );
      PushNotificationSync.instance.notify(message);
      return;
    }

    final payload = PushNotificationPayload.fromRemoteMessage(message);
    final title = payload.title ?? 'FaithConnect';
    final body = payload.body ?? '';

    if (body.isNotEmpty || payload.title != null) {
      unawaited(
        _showLocalForegroundNotification(
          title: title,
          body: body,
          payload: jsonEncode(message.data),
        ),
      );
    }

    _syncAfterPush(message);
  }

  bool _isNewLoginDetectedAlert(RemoteMessage message) {
    final payload = PushNotificationPayload.fromRemoteMessage(message);
    final title = (payload.title ?? '').toLowerCase();
    final body = (payload.body ?? '').toLowerCase();
    final type = (payload.type ?? '').toLowerCase();

    if (title.contains('new login') && title.contains('detect')) return true;
    if (title.contains('login detected')) return true;
    if (body.contains('new login') && body.contains('detect')) return true;
    if (body.contains('login detected')) return true;
    if (type.contains('new_login') || type.contains('login_detected')) {
      return true;
    }
    if (type.contains('login') && type.contains('detect')) return true;
    return false;
  }

  Future<void> _showLocalForegroundNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: Object.hash(title, body, payload),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  void _handleMessage(RemoteMessage message) {
    _logRemoteMessage('message_opened', message);
    if (_isNewLoginDetectedAlert(message)) {
      return;
    }
    _syncAfterPush(message);
    _navigateToNotifications();
  }

  void _syncAfterPush(RemoteMessage message) {
    PushNotificationSync.instance.notify(message);
    final payload = PushNotificationPayload.fromRemoteMessage(message);
    StructuredFcmLog.log(
      step: 'push_notifications_sync',
      message: 'Triggered notification refresh after push',
      details: {
        if (payload.notificationId != null)
          'notification_id': payload.notificationId,
        if (payload.type != null) 'type': payload.type,
        if (payload.targetId != null) 'target_id': payload.targetId,
        ...StructuredFcmLog.remoteMessageDetails(message.data),
      },
    );
  }

  void _logRemoteMessage(String step, RemoteMessage message) {
    final notification = message.notification;
    StructuredFcmLog.log(
      step: step,
      message: message.messageId ?? 'push message',
      details: {
        if (message.messageId != null) 'message_id': message.messageId,
        if (message.from != null) 'from': message.from,
        if (message.collapseKey != null) 'collapse_key': message.collapseKey,
        if (notification?.title != null) 'title': notification!.title,
        if (notification?.body != null) 'body': notification!.body,
        ...StructuredFcmLog.remoteMessageDetails(message.data),
      },
    );
  }

  void _navigateToNotifications() {
    final context = rootNavigatorKey.currentState?.context;
    if (context == null) return;

    try {
      context.push(RoutesConstant.notifications);
    } catch (e) {
      StructuredFcmLog.log(
        step: 'navigation_failed',
        message: 'Failed to navigate after notification: $e',
        level: FcmLogLevel.error,
      );
    }
  }

  Future<String?> getFCMToken() async {
    final token = await FcmTokenFetcher.fetch(_firebaseMessaging);
    if (token != null) {
      StructuredFcmLog.log(
        step: 'token_obtained',
        message:
            'FCM token from Firebase: ${StructuredFcmLog.tokenPreview(token)}',
        details: StructuredFcmLog.tokenDetails(token),
      );
    }
    return token;
  }
}

enum FcmLogLevel { info, warning, error }

abstract final class StructuredFcmLog {
  StructuredFcmLog._();

  static void log({
    required String step,
    required String message,
    FcmLogLevel level = FcmLogLevel.info,
    Map<String, dynamic>? details,
  }) {
    final formattedMessage =
        'Step: $step | $message${details != null ? ' | Details: $details' : ''}';
    switch (level) {
      case FcmLogLevel.info:
        FaithLogger.i('FCM', formattedMessage);
        break;
      case FcmLogLevel.warning:
        FaithLogger.w('FCM', formattedMessage);
        break;
      case FcmLogLevel.error:
        FaithLogger.e('FCM', formattedMessage);
        break;
    }
  }

  static String tokenPreview(String token) {
    if (token.length <= 10) return token;
    return '${token.substring(0, 5)}...${token.substring(token.length - 5)}';
  }

  static Map<String, dynamic> tokenDetails(String token) {
    return {
      'token_length': token.length,
      'token_hash': token.hashCode.toString(),
    };
  }

  static Map<String, dynamic> remoteMessageDetails(Map<String, dynamic> data) {
    return data;
  }
}

abstract final class FcmTokenFetcher {
  FcmTokenFetcher._();

  static Future<String?> fetch(FirebaseMessaging messaging) async {
    try {
      return await messaging.getToken();
    } catch (e) {
      FaithLogger.e('FcmTokenFetcher', 'Error fetching FCM token', e);
      return null;
    }
  }
}
