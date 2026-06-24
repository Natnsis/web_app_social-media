/// Socket.io event names for 1-to-1 `/messaging` namespace.
abstract final class DirectMessagingSocketEvents {
  DirectMessagingSocketEvents._();

  // Client → server
  static const String messageSend = 'message:send';
  static const String messageReply = 'message:reply';
  static const String messageUpdate = 'message:update';
  static const String messageDelete = 'message:delete';
  static const String messageRead = 'message:read';
  static const String typingStart = 'typing:start';
  static const String typingStop = 'typing:stop';

  // Server → client
  static const String messageNew = 'message:new';
  static const String messageUpdated = 'message:updated';
  static const String messageDeleted = 'message:deleted';
  static const String conversationRead = 'conv:read';
  static const String presenceOnline = 'presence:online';
  static const String presenceOffline = 'presence:offline';
}
