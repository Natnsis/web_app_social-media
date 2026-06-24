import 'dart:async';

import 'package:faithconnect/core/config/env_config.dart';
import 'package:faithconnect/core/constants/socket_namespace.dart';
import 'package:faithconnect/core/services/socket/group_chat_socket_events.dart';
import 'package:faithconnect/core/services/socket/group_chat_socket_payloads.dart';
import 'package:faithconnect/core/services/socket/messaging_socket_payloads.dart';
import 'package:faithconnect/core/services/socket/socket_conversation_logger.dart';
import 'package:faithconnect/core/services/socket/socket_services.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Group messaging on `/groups` namespace (not used for 1-to-1 direct chat).
abstract class GroupChatSocketService {
  void ensureConnected();

  bool get isConnected;

  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 5),
  });

  Stream<GroupSocketMessage> get onMessageNew;

  Stream<GroupSocketMessage> get onMessageUpdated;

  Stream<GroupMessageDeletedPayload> get onMessageDeleted;

  bool markMessageSeen({required String groupId, required String messageId});

  Stream<GroupMessageSeenPayload> get onMessageSeen;

  Stream<GroupTypingPayload> get onTypingStart;

  Stream<GroupTypingPayload> get onTypingStop;

  Stream<GroupMemberEventPayload> get onMemberJoined;

  Stream<GroupMemberEventPayload> get onMemberLeft;

  Stream<PresencePayload> get onPresenceOnline;

  Stream<PresencePayload> get onPresenceOffline;

  void emitPresenceOnline({required String userId});

  void emitPresenceOffline({required String userId});

  bool sendMessage({
    required String groupId,
    String body = '',
    String? mediaUrl,
  });

  /// Waits for `/groups` socket connection, then emits `group:message:send`.
  Future<bool> sendMessageAsync({
    required String groupId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  bool sendReply({
    required String groupId,
    required String parentId,
    String body = '',
    String? mediaUrl,
  });

  /// Waits for connection, then emits `group:message:reply`.
  Future<bool> sendReplyAsync({
    required String groupId,
    required String parentId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  bool updateMessage({
    required String groupId,
    required String messageId,
    required String body,
  });

  /// Waits for connection, then emits `group:message:update`.
  Future<bool> updateMessageAsync({
    required String groupId,
    required String messageId,
    required String body,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  bool deleteMessage({
    required String groupId,
    required String messageId,
  });

  /// Waits for connection, then emits `group:message:delete`.
  Future<bool> deleteMessageAsync({
    required String groupId,
    required String messageId,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  void emitTypingStart(String groupId);

  void emitTypingStop(String groupId);
}

class GroupChatSocketServiceImpl implements GroupChatSocketService {
  GroupChatSocketServiceImpl({required SocketService socketService})
      : _socketService = socketService;

  static const _logTag = 'GroupChatSocket';

  final SocketService _socketService;

  final StreamController<GroupSocketMessage> _messageNew =
      StreamController<GroupSocketMessage>.broadcast();
  final StreamController<GroupSocketMessage> _messageUpdated =
      StreamController<GroupSocketMessage>.broadcast();
  final StreamController<GroupMessageDeletedPayload> _messageDeleted =
      StreamController<GroupMessageDeletedPayload>.broadcast();
  final StreamController<GroupMessageSeenPayload> _messageSeen =
      StreamController<GroupMessageSeenPayload>.broadcast();
  final StreamController<GroupTypingPayload> _typingStart =
      StreamController<GroupTypingPayload>.broadcast();
  final StreamController<GroupTypingPayload> _typingStop =
      StreamController<GroupTypingPayload>.broadcast();
  final StreamController<GroupMemberEventPayload> _memberJoined =
      StreamController<GroupMemberEventPayload>.broadcast();
  final StreamController<GroupMemberEventPayload> _memberLeft =
      StreamController<GroupMemberEventPayload>.broadcast();
  final StreamController<PresencePayload> _presenceOnline =
      StreamController<PresencePayload>.broadcast();
  final StreamController<PresencePayload> _presenceOffline =
      StreamController<PresencePayload>.broadcast();

  io.Socket? _listenerSocket;

  @override
  Stream<GroupSocketMessage> get onMessageNew => _messageNew.stream;

  @override
  Stream<GroupSocketMessage> get onMessageUpdated => _messageUpdated.stream;

  @override
  Stream<GroupMessageDeletedPayload> get onMessageDeleted =>
      _messageDeleted.stream;

  @override
  Stream<GroupMessageSeenPayload> get onMessageSeen => _messageSeen.stream;

  @override
  Stream<GroupTypingPayload> get onTypingStart => _typingStart.stream;

  @override
  Stream<GroupTypingPayload> get onTypingStop => _typingStop.stream;

  @override
  Stream<GroupMemberEventPayload> get onMemberJoined => _memberJoined.stream;

  @override
  Stream<GroupMemberEventPayload> get onMemberLeft => _memberLeft.stream;

  @override
  Stream<PresencePayload> get onPresenceOnline => _presenceOnline.stream;

  @override
  Stream<PresencePayload> get onPresenceOffline => _presenceOffline.stream;

  @override
  bool get isConnected => _socketService.isConnected(SocketNamespace.groups);

  @override
  void ensureConnected() {
    SocketConversationLogger.logLifecycle(
      phase: 'ensureConnected',
      namespace: SocketNamespace.groups,
      uri: '${EnvConfig.instance.apiBaseUrl}${SocketNamespace.groups}',
      metadata: const {'transport': 'websocket', 'auth': 'token'},
    );

    final socket = _socketService.connect(SocketNamespace.groups);

    if (_listenerSocket != socket) {
      _listenerSocket = socket;
      _attachListeners(socket);
      SocketConversationLogger.logListenersAttached(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        events: const [
          GroupChatSocketEvents.messageNew,
          GroupChatSocketEvents.messageUpdated,
          GroupChatSocketEvents.messageDeleted,
          GroupChatSocketEvents.messageSeen,
          GroupChatSocketEvents.typingStartIncoming,
          GroupChatSocketEvents.typingStopIncoming,
          GroupChatSocketEvents.memberJoined,
          GroupChatSocketEvents.memberLeft,
          GroupChatSocketEvents.presenceOnline,
          GroupChatSocketEvents.presenceOffline,
        ],
      );
    }
  }

  String? get _socketId => _socketService.socketFor(SocketNamespace.groups)?.id;

  void _attachListeners(io.Socket socket) {
    socket.on(GroupChatSocketEvents.messageNew, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageNew,
        raw: data,
      );
      final parsed = GroupSocketMessage.fromDynamic(data);
      if (parsed.groupId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.messageNew,
          reason: 'missing groupId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageNew,
        conversationId: parsed.groupId,
        details: {
          'messageId': parsed.id,
          'senderId': parsed.senderId,
          'bodyLen': '${parsed.body.length}',
        },
        parsedPayload: {
          'id': parsed.id,
          'groupId': parsed.groupId,
          'senderId': parsed.senderId,
          'body': parsed.body,
          if (parsed.senderName != null) 'senderName': parsed.senderName,
          'createdAt': parsed.createdAt.toIso8601String(),
        },
      );
      if (!_messageNew.isClosed) _messageNew.add(parsed);
    });

    socket.on(GroupChatSocketEvents.messageUpdated, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageUpdated,
        raw: data,
      );
      final parsed = GroupSocketMessage.fromDynamic(data);
      if (parsed.id.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.messageUpdated,
          reason: 'missing message id',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageUpdated,
        conversationId: parsed.groupId,
        details: {
          'messageId': parsed.id,
          'senderId': parsed.senderId,
        },
      );
      if (!_messageUpdated.isClosed) _messageUpdated.add(parsed);
    });

    socket.on(GroupChatSocketEvents.messageDeleted, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageDeleted,
        raw: data,
      );
      final parsed = GroupMessageDeletedPayload.fromDynamic(data);
      if (parsed.messageId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.messageDeleted,
          reason: 'missing messageId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageDeleted,
        conversationId: parsed.groupId ?? 'n/a',
        details: {'messageId': parsed.messageId},
      );
      if (!_messageDeleted.isClosed) _messageDeleted.add(parsed);
    });

    socket.on(GroupChatSocketEvents.messageSeen, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageSeen,
        raw: data,
      );
      final parsed = GroupMessageSeenPayload.fromDynamic(data);
      if (parsed.messageId.isEmpty || parsed.groupId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.messageSeen,
          reason: 'missing messageId or groupId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.messageSeen,
        conversationId: parsed.groupId,
        details: {'messageId': parsed.messageId, 'userId': parsed.userId},
      );
      if (!_messageSeen.isClosed) _messageSeen.add(parsed);
    });

    socket.on(GroupChatSocketEvents.typingStartIncoming, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.typingStartIncoming,
        raw: data,
      );
      final parsed = GroupTypingPayload.fromDynamic(data);
      if (parsed.groupId.isEmpty || parsed.userId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.typingStartIncoming,
          reason: 'missing groupId or userId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.typingStartIncoming,
        conversationId: parsed.groupId,
        details: {'userId': parsed.userId},
      );
      if (!_typingStart.isClosed) _typingStart.add(parsed);
    });

    socket.on(GroupChatSocketEvents.typingStopIncoming, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.typingStopIncoming,
        raw: data,
      );
      final parsed = GroupTypingPayload.fromDynamic(data);
      if (parsed.groupId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.typingStopIncoming,
          reason: 'missing groupId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.typingStopIncoming,
        conversationId: parsed.groupId,
        details: {'userId': parsed.userId},
      );
      if (!_typingStop.isClosed) _typingStop.add(parsed);
    });

    socket.on(GroupChatSocketEvents.memberJoined, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.memberJoined,
        raw: data,
      );
      final parsed = GroupMemberEventPayload.fromDynamic(data, joined: true);
      if (parsed.groupId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.memberJoined,
          reason: 'missing groupId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.memberJoined,
        conversationId: parsed.groupId,
        details: {'userId': parsed.userId},
      );
      if (!_memberJoined.isClosed) _memberJoined.add(parsed);
    });

    socket.on(GroupChatSocketEvents.memberLeft, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.memberLeft,
        raw: data,
      );
      final parsed = GroupMemberEventPayload.fromDynamic(data, joined: false);
      if (parsed.groupId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          socketId: socket.id,
          event: GroupChatSocketEvents.memberLeft,
          reason: 'missing groupId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.memberLeft,
        conversationId: parsed.groupId,
        details: {'userId': parsed.userId},
      );
      if (!_memberLeft.isClosed) _memberLeft.add(parsed);
    });

    socket.on(GroupChatSocketEvents.presenceOnline, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.presenceOnline,
        raw: data,
      );
      final parsed = PresencePayload.fromDynamic(data, isOnline: true);
      if (parsed.userId.isEmpty) return;
      if (!_presenceOnline.isClosed) _presenceOnline.add(parsed);
    });

    socket.on(GroupChatSocketEvents.presenceOffline, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        socketId: socket.id,
        event: GroupChatSocketEvents.presenceOffline,
        raw: data,
      );
      final parsed = PresencePayload.fromDynamic(data, isOnline: false);
      if (parsed.userId.isEmpty) return;
      if (!_presenceOffline.isClosed) _presenceOffline.add(parsed);
    });
  }

  @override
  void emitPresenceOnline({required String userId}) {
    if (!isConnected) return;
    _socketService.socketFor(SocketNamespace.groups)?.emit(GroupChatSocketEvents.presenceOnline, {'userId': userId});
  }

  @override
  void emitPresenceOffline({required String userId}) {
    if (!isConnected) return;
    _socketService.socketFor(SocketNamespace.groups)?.emit(GroupChatSocketEvents.presenceOffline, {'userId': userId});
  }

  @override
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    ensureConnected();
    final connected = await _socketService.waitUntilConnected(
      SocketNamespace.groups,
      timeout: timeout,
    );
    SocketConversationLogger.logConnectionWait(
      tag: _logTag,
      namespace: SocketNamespace.groups,
      timeout: timeout,
      connected: connected,
      socketId: _socketId,
    );
    return connected;
  }

  @override
  Future<bool> sendMessageAsync({
    required String groupId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = GroupMessageSendPayload(groupId: groupId, body: body, mediaUrl: mediaUrl);
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: GroupChatSocketEvents.messageSend,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool sendMessage({
    required String groupId,
    String body = '',
    String? mediaUrl,
  }) {
    final payload = GroupMessageSendPayload(groupId: groupId, body: body, mediaUrl: mediaUrl);
    if (!payload.isValid) return false;

    return _emit(GroupChatSocketEvents.messageSend, payload.toJson());
  }

  @override
  Future<bool> sendReplyAsync({
    required String groupId,
    required String parentId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = GroupMessageReplyPayload(
      groupId: groupId,
      parentId: parentId,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: GroupChatSocketEvents.messageReply,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool sendReply({
    required String groupId,
    required String parentId,
    String body = '',
    String? mediaUrl,
  }) {
    final payload = GroupMessageReplyPayload(
      groupId: groupId,
      parentId: parentId,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!payload.isValid) return false;

    return _emit(GroupChatSocketEvents.messageReply, payload.toJson());
  }

  @override
  Future<bool> updateMessageAsync({
    required String groupId,
    required String messageId,
    required String body,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = GroupMessageUpdatePayload(
      groupId: groupId,
      messageId: messageId,
      body: body,
    );
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: GroupChatSocketEvents.messageUpdate,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool updateMessage({
    required String groupId,
    required String messageId,
    required String body,
  }) {
    final payload = GroupMessageUpdatePayload(
      groupId: groupId,
      messageId: messageId,
      body: body,
    );
    if (!payload.isValid) return false;

    return _emit(GroupChatSocketEvents.messageUpdate, payload.toJson());
  }

  @override
  Future<bool> deleteMessageAsync({
    required String groupId,
    required String messageId,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = GroupMessageDeletePayload(
      groupId: groupId,
      messageId: messageId,
    );
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: GroupChatSocketEvents.messageDelete,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool deleteMessage({
    required String groupId,
    required String messageId,
  }) {
    final payload = GroupMessageDeletePayload(
      groupId: groupId,
      messageId: messageId,
    );
    if (!payload.isValid) return false;

    return _emit(GroupChatSocketEvents.messageDelete, payload.toJson());
  }

  @override
  bool markMessageSeen({required String groupId, required String messageId}) {
    if (!isConnected) return false;
    FaithLogger.d(_logTag, 'Emitting group:message:read => messageId=$messageId');
    return _emit(GroupChatSocketEvents.messageRead, {
      'groupId': groupId,
      'messageId': messageId,
    });
  }

  @override
  void emitTypingStart(String groupId) {
    _emitTyping(groupId, GroupChatSocketEvents.typingStart);
  }

  @override
  void emitTypingStop(String groupId) {
    _emitTyping(groupId, GroupChatSocketEvents.typingStop);
  }

  void _emitTyping(String groupId, String event) {
    final payload = GroupTypingEmitPayload(groupId: groupId);
    if (!payload.isValid) return;
    _emit(event, payload.toJson(), requireConnected: false);
  }

  Future<bool> _emitWhenConnected({
    required String event,
    required Map<String, dynamic> payload,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) async {
    ensureConnected();
    final connected = await waitForConnection(timeout: connectionTimeout);
    if (!connected) {
      SocketConversationLogger.logEmitSkipped(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        event: event,
        reason: 'socket not connected after wait',
        payload: payload,
      );
      return false;
    }
    return _emit(event, payload);
  }

  bool _emit(
    String event,
    Map<String, dynamic> payload, {
    bool requireConnected = true,
  }) {
    ensureConnected();
    final socket = _socketService.socketFor(SocketNamespace.groups);
    if (socket == null) {
      SocketConversationLogger.logEmitSkipped(
        tag: _logTag,
        namespace: SocketNamespace.groups,
        event: event,
        reason: 'socket not initialized',
        payload: payload,
      );
      return false;
    }

    if (!socket.connected) {
      if (requireConnected) {
        SocketConversationLogger.logEmitSkipped(
          tag: _logTag,
          namespace: SocketNamespace.groups,
          event: event,
          reason: 'socket not connected',
          payload: payload,
        );
        return false;
      }
      socket.connect();
    }

    SocketConversationLogger.logEmit(
      tag: _logTag,
      namespace: SocketNamespace.groups,
      socketId: socket.id,
      connected: socket.connected,
      event: event,
      payload: payload,
    );
    socket.emit(event, payload);
    return true;
  }
}
