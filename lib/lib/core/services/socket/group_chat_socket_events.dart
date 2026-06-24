/// Socket.io event names for group `/groups` namespace.
abstract final class GroupChatSocketEvents {
  GroupChatSocketEvents._();

  // Client → server
  static const String messageSend = 'group:message:send';
  static const String messageReply = 'group:message:reply';
  static const String messageUpdate = 'group:message:update';
  static const String messageDelete = 'group:message:delete';
  static const String typingStart = 'group:typing:start';
  static const String typingStop = 'group:typing:stop';
  static const String messageRead = 'group:message:read';

  // Server → client
  static const String messageNew = 'group:message:new';
  static const String messageUpdated = 'group:message:updated';
  static const String messageDeleted = 'group:message:deleted';
  static const String messageSeen = 'group:message:seen';
  static const String typingStartIncoming = 'group:typing:start';
  static const String typingStopIncoming = 'group:typing:stop';
  static const String memberJoined = 'group:member:joined';
  static const String memberLeft = 'group:member:left';
  static const String presenceOnline = 'presence:online';
  static const String presenceOffline = 'presence:offline';
}
