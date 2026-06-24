import 'dart:async';

import 'package:faithconnect/core/config/env_config.dart';
import 'package:faithconnect/core/constants/socket_namespace.dart';
import 'package:faithconnect/core/services/socket/direct_messaging_socket_events.dart';
import 'package:faithconnect/core/services/socket/messaging_socket_payloads.dart';
import 'package:faithconnect/core/services/socket/socket_conversation_logger.dart';
import 'package:faithconnect/core/services/socket/socket_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// 1-to-1 direct messaging on `/messaging` (not used for group chats).
abstract class DirectMessagingSocketService {
  void ensureConnected();

  bool get isConnected;

  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 5),
  });

  Stream<MessagingSocketMessage> get onMessageNew;

  Stream<MessagingSocketMessage> get onMessageUpdated;

  Stream<MessageDeletedPayload> get onMessageDeleted;

  Stream<ConversationReadPayload> get onConversationRead;

  Stream<TypingPayload> get onTypingStart;

  Stream<TypingPayload> get onTypingStop;

  Stream<PresencePayload> get onPresenceOnline;

  Stream<PresencePayload> get onPresenceOffline;

  void emitPresenceOnline({required String userId});

  void emitPresenceOffline({required String userId});

  /// Existing conversation — provide [conversationId] only.
  /// First message — provide [recipientId] only (conversation auto-created).
  bool sendMessage({
    String? conversationId,
    String? recipientId,
    String body = '',
    String? mediaUrl,
  });

  /// Waits for `/messaging` socket connection, then emits `message:send`.
  Future<bool> sendMessageAsync({
    String? conversationId,
    String? recipientId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  bool sendReply({
    required String conversationId,
    required String replyToId,
    String body = '',
    String? mediaUrl,
  });

  Future<bool> sendReplyAsync({
    required String conversationId,
    required String replyToId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  bool updateMessage({
    required String messageId,
    required String body,
  });

  Future<bool> updateMessageAsync({
    required String messageId,
    required String body,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  bool deleteMessage({required String messageId});

  Future<bool> deleteMessageAsync({
    required String messageId,
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  bool markConversationRead(String conversationId);

  Future<bool> markConversationReadAsync(
    String conversationId, {
    Duration connectionTimeout = const Duration(seconds: 8),
  });

  void emitTypingStart(String conversationId);

  void emitTypingStop(String conversationId);
}

class DirectMessagingSocketServiceImpl implements DirectMessagingSocketService {
  DirectMessagingSocketServiceImpl({required SocketService socketService})
      : _socketService = socketService;

  static const _logTag = 'DirectMessagingSocket';

  final SocketService _socketService;

  final StreamController<MessagingSocketMessage> _messageNew =
      StreamController<MessagingSocketMessage>.broadcast();
  final StreamController<MessagingSocketMessage> _messageUpdated =
      StreamController<MessagingSocketMessage>.broadcast();
  final StreamController<MessageDeletedPayload> _messageDeleted =
      StreamController<MessageDeletedPayload>.broadcast();
  final StreamController<ConversationReadPayload> _conversationRead =
      StreamController<ConversationReadPayload>.broadcast();
  final StreamController<TypingPayload> _typingStart =
      StreamController<TypingPayload>.broadcast();
  final StreamController<TypingPayload> _typingStop =
      StreamController<TypingPayload>.broadcast();
  final StreamController<PresencePayload> _presenceOnline =
      StreamController<PresencePayload>.broadcast();
  final StreamController<PresencePayload> _presenceOffline =
      StreamController<PresencePayload>.broadcast();

  io.Socket? _listenerSocket;

  @override
  Stream<MessagingSocketMessage> get onMessageNew => _messageNew.stream;

  @override
  Stream<MessagingSocketMessage> get onMessageUpdated => _messageUpdated.stream;

  @override
  Stream<MessageDeletedPayload> get onMessageDeleted => _messageDeleted.stream;

  @override
  Stream<ConversationReadPayload> get onConversationRead =>
      _conversationRead.stream;

  @override
  Stream<TypingPayload> get onTypingStart => _typingStart.stream;

  @override
  Stream<TypingPayload> get onTypingStop => _typingStop.stream;

  @override
  Stream<PresencePayload> get onPresenceOnline => _presenceOnline.stream;

  @override
  Stream<PresencePayload> get onPresenceOffline => _presenceOffline.stream;

  @override
  bool get isConnected =>
      _socketService.isConnected(SocketNamespace.messaging);

  @override
  void ensureConnected() {
    SocketConversationLogger.logLifecycle(
      phase: 'ensureConnected',
      namespace: SocketNamespace.messaging,
      uri: '${EnvConfig.instance.apiBaseUrl}${SocketNamespace.messaging}',
      metadata: const {'transport': 'websocket', 'auth': 'token'},
    );

    final socket = _socketService.connect(SocketNamespace.messaging);

    if (_listenerSocket != socket) {
      _listenerSocket = socket;
      _attachListeners(socket);
      SocketConversationLogger.logListenersAttached(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        events: const [
          DirectMessagingSocketEvents.messageNew,
          DirectMessagingSocketEvents.messageUpdated,
          DirectMessagingSocketEvents.messageDeleted,
          DirectMessagingSocketEvents.conversationRead,
          DirectMessagingSocketEvents.messageRead,
          DirectMessagingSocketEvents.typingStart,
          DirectMessagingSocketEvents.typingStop,
          DirectMessagingSocketEvents.presenceOnline,
          DirectMessagingSocketEvents.presenceOffline,
        ],
      );
    }
  }

  String? get _socketId =>
      _socketService.socketFor(SocketNamespace.messaging)?.id;

  void _attachListeners(io.Socket socket) {
    socket.on(DirectMessagingSocketEvents.messageNew, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.messageNew,
        raw: data,
      );
      final parsed = MessagingSocketMessage.fromDynamic(data);
      if (parsed.conversationId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.messaging,
          socketId: socket.id,
          event: DirectMessagingSocketEvents.messageNew,
          reason: 'missing conversationId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.messageNew,
        conversationId: parsed.conversationId,
        details: {
          'messageId': parsed.id,
          'senderId': parsed.senderId,
          'bodyLen': '${parsed.body.length}',
        },
        parsedPayload: {
          'id': parsed.id,
          'conversationId': parsed.conversationId,
          'senderId': parsed.senderId,
          'body': parsed.body,
          if (parsed.senderName != null) 'senderName': parsed.senderName,
          'createdAt': parsed.createdAt.toIso8601String(),
        },
      );
      if (!_messageNew.isClosed) _messageNew.add(parsed);
    });

    socket.on(DirectMessagingSocketEvents.messageUpdated, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.messageUpdated,
        raw: data,
      );
      final parsed = MessagingSocketMessage.fromDynamic(data);
      if (parsed.id.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.messaging,
          socketId: socket.id,
          event: DirectMessagingSocketEvents.messageUpdated,
          reason: 'missing message id',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.messageUpdated,
        conversationId: parsed.conversationId,
        details: {
          'messageId': parsed.id,
          'senderId': parsed.senderId,
        },
      );
      if (!_messageUpdated.isClosed) _messageUpdated.add(parsed);
    });

    socket.on(DirectMessagingSocketEvents.messageDeleted, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.messageDeleted,
        raw: data,
      );
      final parsed = MessageDeletedPayload.fromDynamic(data);
      if (parsed.messageId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.messaging,
          socketId: socket.id,
          event: DirectMessagingSocketEvents.messageDeleted,
          reason: 'missing messageId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.messageDeleted,
        conversationId: parsed.conversationId ?? 'n/a',
        details: {'messageId': parsed.messageId},
      );
      if (!_messageDeleted.isClosed) _messageDeleted.add(parsed);
    });

    socket.on(DirectMessagingSocketEvents.conversationRead, (data) {
      _dispatchReadReceipt(
        data,
        event: DirectMessagingSocketEvents.conversationRead,
        socketId: socket.id,
      );
    });

    socket.on(DirectMessagingSocketEvents.messageRead, (data) {
      _dispatchReadReceipt(
        data,
        event: DirectMessagingSocketEvents.messageRead,
        socketId: socket.id,
      );
    });

    socket.on(DirectMessagingSocketEvents.typingStart, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.typingStart,
        raw: data,
      );
      final parsed = TypingPayload.fromDynamic(data);
      if (parsed.conversationId.isEmpty || parsed.userId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.messaging,
          socketId: socket.id,
          event: DirectMessagingSocketEvents.typingStart,
          reason: 'missing conversationId or userId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.typingStart,
        conversationId: parsed.conversationId,
        details: {'userId': parsed.userId},
      );
      if (!_typingStart.isClosed) _typingStart.add(parsed);
    });

    socket.on(DirectMessagingSocketEvents.typingStop, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.typingStop,
        raw: data,
      );
      final parsed = TypingPayload.fromDynamic(data);
      if (parsed.conversationId.isEmpty) {
        SocketConversationLogger.logDropped(
          tag: _logTag,
          namespace: SocketNamespace.messaging,
          socketId: socket.id,
          event: DirectMessagingSocketEvents.typingStop,
          reason: 'missing conversationId',
          raw: data,
        );
        return;
      }
      SocketConversationLogger.logDispatched(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.typingStop,
        conversationId: parsed.conversationId,
        details: {'userId': parsed.userId},
      );
      if (!_typingStop.isClosed) _typingStop.add(parsed);
    });

    socket.on(DirectMessagingSocketEvents.presenceOnline, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.presenceOnline,
        raw: data,
      );
      final parsed = PresencePayload.fromDynamic(data, isOnline: true);
      if (parsed.userId.isEmpty) return;
      if (!_presenceOnline.isClosed) _presenceOnline.add(parsed);
    });

    socket.on(DirectMessagingSocketEvents.presenceOffline, (data) {
      SocketConversationLogger.logReceive(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socket.id,
        event: DirectMessagingSocketEvents.presenceOffline,
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
    _socketService.socketFor(SocketNamespace.messaging)?.emit(DirectMessagingSocketEvents.presenceOnline, {'userId': userId});
  }

  @override
  void emitPresenceOffline({required String userId}) {
    if (!isConnected) return;
    _socketService.socketFor(SocketNamespace.messaging)?.emit(DirectMessagingSocketEvents.presenceOffline, {'userId': userId});
  }

  void _dispatchReadReceipt(
    dynamic data, {
    required String event,
    String? socketId,
  }) {
    SocketConversationLogger.logReceive(
      tag: _logTag,
      namespace: SocketNamespace.messaging,
      socketId: socketId,
      event: event,
      raw: data,
    );
    final parsed = ConversationReadPayload.fromDynamic(data);
    if (parsed.conversationId.isEmpty) {
      SocketConversationLogger.logDropped(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        socketId: socketId,
        event: event,
        reason: 'missing conversationId',
        raw: data,
      );
      return;
    }
    SocketConversationLogger.logDispatched(
      tag: _logTag,
      namespace: SocketNamespace.messaging,
      socketId: socketId,
      event: event,
      conversationId: parsed.conversationId,
      details: {'readBy': parsed.readBy},
    );
    if (!_conversationRead.isClosed) _conversationRead.add(parsed);
  }

  @override
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    ensureConnected();
    final connected = await _socketService.waitUntilConnected(
      SocketNamespace.messaging,
      timeout: timeout,
    );
    SocketConversationLogger.logConnectionWait(
      tag: _logTag,
      namespace: SocketNamespace.messaging,
      timeout: timeout,
      connected: connected,
      socketId: _socketId,
    );
    return connected;
  }

  @override
  Future<bool> sendMessageAsync({
    String? conversationId,
    String? recipientId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = DirectMessageSendPayload(
      conversationId: conversationId,
      recipientId: recipientId,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: DirectMessagingSocketEvents.messageSend,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool sendMessage({
    String? conversationId,
    String? recipientId,
    String body = '',
    String? mediaUrl,
  }) {
    final payload = DirectMessageSendPayload(
      conversationId: conversationId,
      recipientId: recipientId,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!payload.isValid) {
      SocketConversationLogger.logEmitSkipped(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
        event: DirectMessagingSocketEvents.messageSend,
        reason: (payload.body?.trim().isEmpty ?? true) && (payload.mediaUrl?.trim().isEmpty ?? true)
            ? 'empty body and mediaUrl'
            : 'requires conversationId XOR recipientId',
      );
      return false;
    }

    return _emit(DirectMessagingSocketEvents.messageSend, payload.toJson());
  }

  @override
  Future<bool> sendReplyAsync({
    required String conversationId,
    required String replyToId,
    String body = '',
    String? mediaUrl,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = DirectMessageReplyPayload(
      conversationId: conversationId,
      replyToId: replyToId,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: DirectMessagingSocketEvents.messageReply,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool sendReply({
    required String conversationId,
    required String replyToId,
    String body = '',
    String? mediaUrl,
  }) {
    final payload = DirectMessageReplyPayload(
      conversationId: conversationId,
      replyToId: replyToId,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!payload.isValid) return false;

    return _emit(DirectMessagingSocketEvents.messageReply, payload.toJson());
  }

  @override
  Future<bool> updateMessageAsync({
    required String messageId,
    required String body,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = DirectMessageUpdatePayload(messageId: messageId, body: body);
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: DirectMessagingSocketEvents.messageUpdate,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool updateMessage({
    required String messageId,
    required String body,
  }) {
    final payload = DirectMessageUpdatePayload(messageId: messageId, body: body);
    if (!payload.isValid) return false;

    return _emit(DirectMessagingSocketEvents.messageUpdate, payload.toJson());
  }

  @override
  Future<bool> deleteMessageAsync({
    required String messageId,
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = DirectMessageDeletePayload(messageId: messageId);
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: DirectMessagingSocketEvents.messageDelete,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool deleteMessage({required String messageId}) {
    final payload = DirectMessageDeletePayload(messageId: messageId);
    if (!payload.isValid) return false;

    return _emit(DirectMessagingSocketEvents.messageDelete, payload.toJson());
  }

  @override
  Future<bool> markConversationReadAsync(
    String conversationId, {
    Duration connectionTimeout = const Duration(seconds: 8),
  }) {
    final payload = DirectConversationReadPayload(conversationId: conversationId);
    if (!payload.isValid) return Future.value(false);
    return _emitWhenConnected(
      event: DirectMessagingSocketEvents.messageRead,
      payload: payload.toJson(),
      connectionTimeout: connectionTimeout,
    );
  }

  @override
  bool markConversationRead(String conversationId) {
    final payload = DirectConversationReadPayload(conversationId: conversationId);
    if (!payload.isValid) return false;

    return _emit(DirectMessagingSocketEvents.messageRead, payload.toJson());
  }

  @override
  void emitTypingStart(String conversationId) {
    _emitTyping(conversationId, DirectMessagingSocketEvents.typingStart);
  }

  @override
  void emitTypingStop(String conversationId) {
    _emitTyping(conversationId, DirectMessagingSocketEvents.typingStop);
  }

  void _emitTyping(String conversationId, String event) {
    final payload = DirectTypingEmitPayload(conversationId: conversationId);
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
        namespace: SocketNamespace.messaging,
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
    final socket = _socketService.socketFor(SocketNamespace.messaging);
    if (socket == null) {
      SocketConversationLogger.logEmitSkipped(
        tag: _logTag,
        namespace: SocketNamespace.messaging,
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
          namespace: SocketNamespace.messaging,
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
      namespace: SocketNamespace.messaging,
      socketId: socket.id,
      connected: socket.connected,
      event: event,
      payload: payload,
    );
    socket.emit(event, payload);
    return true;
  }
}
