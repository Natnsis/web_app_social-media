import 'package:firebase_messaging/firebase_messaging.dart';

/// Parsed navigation hints from FCM [RemoteMessage.data].
class PushNotificationPayload {
  final String? notificationId;
  final String? type;
  final String? targetId;
  final String? title;
  final String? body;

  const PushNotificationPayload({
    this.notificationId,
    this.type,
    this.targetId,
    this.title,
    this.body,
  });

  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    return PushNotificationPayload(
      notificationId: _firstNonEmpty([
        data['notificationId'],
        data['notification_id'],
        data['id'],
      ]),
      type: _firstNonEmpty([
        data['type'],
        data['event'],
        data['category'],
        data['templateKey'],
        data['template_key'],
      ]),
      targetId: _firstNonEmpty([
        data['targetId'],
        data['target_id'],
        data['postId'],
        data['post_id'],
        data['shortId'],
        data['short_id'],
        data['conversationId'],
        data['conversation_id'],
      ]),
      title: _firstNonEmpty([
        notification?.title,
        data['title'],
      ]),
      body: _firstNonEmpty([
        notification?.body,
        data['body'],
        data['message'],
      ]),
    );
  }

  static String? _firstNonEmpty(Iterable<Object?> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
