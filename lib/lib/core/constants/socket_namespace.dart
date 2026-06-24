/// Socket.io namespace paths (append to [EnvConfig.apiBaseUrl]).
abstract final class SocketNamespace {
  SocketNamespace._();

  /// Legacy community chat (`/chat`).
  static const String chat = '/chat';

  /// 1-to-1 direct messaging (`/messaging`).
  static const String messaging = '/messaging';

  /// Group messaging (`/groups`).
  static const String groups = '/groups';

  /// Live notifications (`/notifications`).
  static const String notifications = '/notifications';

  /// Live stream presence and events (`/live`).
  static const String live = '/live';

  /// Live GPS coordinate streaming (`/user-location`).
  static const String userLocation = '/user-location';

  /// Live stream comment events (`/livestream`).
  static const String livestream = '/livestream';
}

/// Server-side WebSocket auth failure code.
abstract final class SocketAuthError {
  SocketAuthError._();

  static const String wsAuthFailed = 'WS_AUTH_FAILED';
}
