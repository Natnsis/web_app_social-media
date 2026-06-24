import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';

/// Background FCM handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    FaithLogger.i(
      'FCM',
      'Background message: ${message.messageId ?? 'unknown'}',
    );
  } catch (e) {
    FaithLogger.e('FCM', 'Background handler failed: $e');
  }
}
