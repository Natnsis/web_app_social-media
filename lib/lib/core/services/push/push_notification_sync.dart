import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:faithconnect/core/services/push/push_notification_payload.dart';

typedef PushNotificationCallback = void Function(PushNotificationPayload payload);

/// Lightweight bridge between FCM handlers and app-level notification refresh.
class PushNotificationSync {
  PushNotificationSync._();

  static final PushNotificationSync instance = PushNotificationSync._();

  PushNotificationCallback? onInboundPush;

  void notify(RemoteMessage message) {
    onInboundPush?.call(PushNotificationPayload.fromRemoteMessage(message));
  }
}
