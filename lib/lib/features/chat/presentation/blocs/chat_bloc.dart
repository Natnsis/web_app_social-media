import 'dart:async';

import 'package:faithconnect/core/constants/socket_namespace.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/services/socket/direct_messaging_socket_service.dart';
import 'package:faithconnect/core/services/socket/group_chat_socket_service.dart';
import 'package:faithconnect/core/services/socket/messaging_socket_payloads.dart';
import 'package:faithconnect/core/services/socket/socket_services.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/core/utils/group_access_errors.dart';
import 'package:faithconnect/features/chat/application/chat_service.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_delivery_status.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_reply_preview.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/domain/utils/chat_message_enricher.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_event.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static const _logTag = 'ChatBloc';

  ChatBloc({
    required ChatService chatService,
    required SocketService socketService,
    required DirectMessagingSocketService directMessagingSocket,
    required GroupChatSocketService groupChatSocket,
  })  : _chatService = chatService,
        _socketService = socketService,
        _directMessaging = directMessagingSocket,
        _groupChat = groupChatSocket,
        super(const ChatInitial()) {
    on<ChatRoomsRequested>(_onRoomsRequested);
    on<ChatRoomsRefreshed>(_onRoomsRefreshed);
    on<ChatListRestoreRequested>(_onListRestoreRequested);
    on<ChatDirectRoomPrepared>(_onDirectRoomPrepared);
    on<ChatThreadRequested>(_onThreadRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatSendErrorDismissed>(_onSendErrorDismissed);
    on<ChatMessagingThreadOpened>(_onMessagingThreadOpened);
    on<ChatMessagingThreadClosed>(_onMessagingThreadClosed);
    on<ChatIncomingMessageReceived>(_onIncomingMessage);
    on<ChatMessageUpdatedReceived>(_onMessageUpdated);
    on<ChatMessageDeletedReceived>(_onMessageDeleted);
    on<ChatConversationReadUpdated>(_onConversationRead);
    on<ChatGroupMessageSeen>(_onGroupMessageSeen);
    on<ChatMessageSeenByMe>(_onMessageSeenByMe);
    on<ChatPeerTypingChanged>(_onPeerTypingChanged);
    on<ChatTypingStarted>(_onTypingStarted);
    on<ChatTypingStopped>(_onTypingStopped);
    on<ChatReplySent>(_onReplySent);
    on<ChatDirectReplySent>(_onLegacyDirectReplySent);
    on<ChatMessageEditSent>(_onMessageEditSent);
    on<ChatMessageDeleteSent>(_onMessageDeleteSent);
    on<ChatDirectMessageUpdated>(_onLegacyDirectMessageUpdated);
    on<ChatDirectMessageDeleted>(_onLegacyDirectMessageDeleted);
    on<ChatSocketConnectionChanged>(_onSocketConnectionChanged);
    on<ChatPresenceStatusChanged>(_onPresenceStatusChanged);
    on<ChatUserBlockRequested>(_onUserBlockRequested);
    on<ChatUserUnblockRequested>(_onUserUnblockRequested);

    _socketConnectionSub = _socketService.onNamespaceConnectionChanged.listen(
      (event) => add(
        ChatSocketConnectionChanged(
          namespace: event.namespace,
          isConnected: event.isConnected,
        ),
      ),
    );

    _messageSub = _directMessaging.onMessageNew.listen(
      (message) => add(ChatIncomingMessageReceived(message)),
    );
    _messageUpdatedSub = _directMessaging.onMessageUpdated.listen(
      (message) => add(ChatMessageUpdatedReceived(message)),
    );
    _messageDeletedSub = _directMessaging.onMessageDeleted.listen(
      (payload) => add(ChatMessageDeletedReceived(payload)),
    );
    _readSub = _directMessaging.onConversationRead.listen(
      (payload) => add(ChatConversationReadUpdated(payload)),
    );
    _typingStartSub = _directMessaging.onTypingStart.listen((payload) {
      add(
        ChatPeerTypingChanged(
          conversationId: payload.conversationId,
          userId: payload.userId,
          isTyping: true,
        ),
      );
    });
    _typingStopSub = _directMessaging.onTypingStop.listen((payload) {
      add(
        ChatPeerTypingChanged(
          conversationId: payload.conversationId,
          isTyping: false,
        ),
      );
    });

    _groupMessageSub = _groupChat.onMessageNew.listen(
      (message) => add(ChatIncomingMessageReceived(message.toMessagingFormat())),
    );
    _groupMessageUpdatedSub = _groupChat.onMessageUpdated.listen(
      (message) => add(ChatMessageUpdatedReceived(message.toMessagingFormat())),
    );
    _groupMessageDeletedSub = _groupChat.onMessageDeleted.listen(
      (payload) =>
          add(ChatMessageDeletedReceived(payload.toMessagingFormat())),
    );
    _groupTypingStartSub = _groupChat.onTypingStart.listen((payload) {
      add(
        ChatPeerTypingChanged(
          conversationId: payload.groupId,
          userId: payload.userId,
          isTyping: true,
        ),
      );
    });
    _groupTypingStopSub = _groupChat.onTypingStop.listen((payload) {
      add(ChatPeerTypingChanged(
        conversationId: payload.groupId,
        userId: payload.userId,
        isTyping: false,
      ));
    });
    _groupMessageSeenSub = _groupChat.onMessageSeen.listen((payload) {
      add(ChatGroupMessageSeen(payload));
    });

    _directPresenceOnlineSub = _directMessaging.onPresenceOnline.listen(
      (payload) => add(ChatPresenceStatusChanged(payload)),
    );
    _directPresenceOfflineSub = _directMessaging.onPresenceOffline.listen(
      (payload) => add(ChatPresenceStatusChanged(payload)),
    );
    _groupPresenceOnlineSub = _groupChat.onPresenceOnline.listen(
      (payload) => add(ChatPresenceStatusChanged(payload)),
    );
    _groupPresenceOfflineSub = _groupChat.onPresenceOffline.listen(
      (payload) => add(ChatPresenceStatusChanged(payload)),
    );
  }

  final ChatService _chatService;
  final SocketService _socketService;
  final DirectMessagingSocketService _directMessaging;
  final GroupChatSocketService _groupChat;
  List<ChatRoom> _cachedRooms = const [];
  ChatRoomType? _pendingRestoreInboxTab;
  String? _currentUserId;
  String? _openMessagingRoomId;
  bool _messagingSocketWasDisconnected = false;
  bool _groupsSocketWasDisconnected = false;
  StreamSubscription<dynamic>? _messageSub;
  StreamSubscription<dynamic>? _messageUpdatedSub;
  StreamSubscription<dynamic>? _messageDeletedSub;
  StreamSubscription<dynamic>? _readSub;
  StreamSubscription<dynamic>? _typingStartSub;
  StreamSubscription<dynamic>? _typingStopSub;
  StreamSubscription<dynamic>? _groupMessageSub;
  StreamSubscription<dynamic>? _groupMessageUpdatedSub;
  StreamSubscription<dynamic>? _groupMessageDeletedSub;
  StreamSubscription<dynamic>? _groupTypingStartSub;
  StreamSubscription<dynamic>? _groupTypingStopSub;
  StreamSubscription<dynamic>? _groupMessageSeenSub;
  StreamSubscription<dynamic>? _socketConnectionSub;
  StreamSubscription<dynamic>? _directPresenceOnlineSub;
  StreamSubscription<dynamic>? _directPresenceOfflineSub;
  StreamSubscription<dynamic>? _groupPresenceOnlineSub;
  StreamSubscription<dynamic>? _groupPresenceOfflineSub;

  List<ChatRoom> get cachedRooms => _cachedRooms;

  @override
  Future<void> close() {
    if (_currentUserId != null) {
      _directMessaging.emitPresenceOffline(userId: _currentUserId!);
      _groupChat.emitPresenceOffline(userId: _currentUserId!);
    }
    _socketConnectionSub?.cancel();
    _messageSub?.cancel();
    _messageUpdatedSub?.cancel();
    _messageDeletedSub?.cancel();
    _readSub?.cancel();
    _typingStartSub?.cancel();
    _typingStopSub?.cancel();
    _groupMessageSub?.cancel();
    _groupMessageUpdatedSub?.cancel();
    _groupMessageDeletedSub?.cancel();
    _groupMessageSeenSub?.cancel();
    _groupTypingStartSub?.cancel();
    _groupTypingStopSub?.cancel();
    _socketConnectionSub?.cancel();
    _directPresenceOnlineSub?.cancel();
    _directPresenceOfflineSub?.cancel();
    _groupPresenceOnlineSub?.cancel();
    _groupPresenceOfflineSub?.cancel();
    return super.close();
  }

  bool _isSocketConnectedForRoom(ChatRoom room) {
    if (room.isDirect) return _directMessaging.isConnected;
    if (room.isGroup) return _groupChat.isConnected;
    return true;
  }

  Future<String?> _resolveUserId() async {
    if (_currentUserId != null && _currentUserId!.trim().isNotEmpty) {
      return _currentUserId;
    }
    final storedId = await SharedPrefsService.getUserId();
    if (storedId != null && storedId.trim().isNotEmpty) {
      _currentUserId = storedId.trim();
      return _currentUserId;
    }
    final user = await SharedPrefsService.getUser();
    _currentUserId = user?.id?.trim();
    return _currentUserId;
  }

  ChatRoom? _roomById(String roomId) {
    final current = state;
    if (current is ChatThreadLoaded && current.room.id == roomId) {
      return current.room;
    }
    for (final room in _cachedRooms) {
      if (room.id == roomId) return room;
    }
    return null;
  }

  bool _isDirectRoom(String roomId) => _roomById(roomId)?.isDirect ?? false;

  bool _isGroupRoom(String roomId) => _roomById(roomId)?.isGroup ?? false;

  ChatThreadLoaded _enriched(ChatThreadLoaded state) {
    return state.copyWith(
      messages: ChatMessageEnricher.enrich(
        state.messages,
        peerUserId: state.room.isDirect ? state.room.peerUserId : null,
        lastReadByUserId: state.lastReadByUserId,
      ),
    );
  }

  void _emitThread(Emitter<ChatState> emit, ChatThreadLoaded state) {
    emit(_enriched(state));
  }

  ChatMessage? _findMessage(List<ChatMessage> messages, String id) {
    for (final message in messages) {
      if (message.id == id) return message;
    }
    return null;
  }

  ChatMessageReplyPreview? _replyPreviewFor(
    List<ChatMessage> messages,
    String replyToId,
  ) {
    final original = _findMessage(messages, replyToId);
    if (original == null) return null;

    // Forward the attachment URL so the reply-quote strip can show a thumbnail.
    final mediaUrl = original.attachmentPath?.trim().isNotEmpty == true &&
            (original.attachmentPath!.startsWith('http://') ||
                original.attachmentPath!.startsWith('https://'))
        ? original.attachmentPath
        : null;

    return ChatMessageReplyPreview(
      messageId: original.id,
      senderName: original.isMine ? 'You' : original.senderName,
      content: original.content,
      isOriginalMine: original.isMine,
      mediaUrl: mediaUrl,
    );
  }


  Future<void> _onRoomsRequested(
    ChatRoomsRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatListLoading());
    await _loadRooms(emit);
  }

  Future<void> _onRoomsRefreshed(
    ChatRoomsRefreshed event,
    Emitter<ChatState> emit,
  ) async {
    await _loadRooms(emit);
  }

  Future<void> _loadRooms(Emitter<ChatState> emit) async {
    final userId = await _resolveUserId();
    if (userId != null) {
      _directMessaging.ensureConnected();
      _groupChat.ensureConnected();

      if (_directMessaging.isConnected) {
        _directMessaging.emitPresenceOnline(userId: userId);
      }
      if (_groupChat.isConnected) {
        _groupChat.emitPresenceOnline(userId: userId);
      }
    }

    final result = await _chatService.getRooms();
    result.fold(
      (failure) {
        if (_cachedRooms.isEmpty) {
          emit(ChatFailureState(failure.message));
        } else {
          emit(ChatRoomsLoaded(List<ChatRoom>.from(_cachedRooms)));
        }
      },
      (rooms) {
        _cachedRooms = rooms;
        final restoreTab = _pendingRestoreInboxTab;
        _pendingRestoreInboxTab = null;
        emit(ChatRoomsLoaded(rooms, restoreInboxTab: restoreTab));
      },
    );
  }

  void _onListRestoreRequested(
    ChatListRestoreRequested event,
    Emitter<ChatState> emit,
  ) {
    _pendingRestoreInboxTab = event.inboxTab;
    if (_cachedRooms.isNotEmpty) {
      emit(
        ChatRoomsLoaded(
          List<ChatRoom>.from(_cachedRooms),
          restoreInboxTab: event.inboxTab,
        ),
      );
      _pendingRestoreInboxTab = null;
    } else {
      add(const ChatRoomsRequested());
    }
  }

  void _onDirectRoomPrepared(
    ChatDirectRoomPrepared event,
    Emitter<ChatState> emit,
  ) {
    final peerId = event.userId.trim();
    if (peerId.isEmpty) return;

    final exists = _cachedRooms.any(
      (room) =>
          room.isDirect &&
          (room.id == peerId || room.peerUserId == peerId),
    );
    if (exists) return;

    final title = event.displayName.trim();
    final room = ChatRoom(
      id: peerId,
      title: title.isNotEmpty ? title : 'Member',
      type: ChatRoomType.direct,
      peerUserId: peerId,
      avatarUrl: event.avatarUrl,
      initials: title.isNotEmpty ? title[0].toUpperCase() : 'M',
    );

    _cachedRooms = [room, ..._cachedRooms];
    final current = state;
    if (current is ChatRoomsLoaded) {
      emit(current.copyWith(rooms: List<ChatRoom>.from(_cachedRooms)));
    }
  }

  void _onMessagingThreadOpened(
    ChatMessagingThreadOpened event,
    Emitter<ChatState> emit,
  ) {
    _openMessagingRoomId = event.roomId;
    final room = _roomById(event.roomId);
    final roomType = event.roomType ?? room?.type;

    FaithLogger.d(
      _logTag,
      'THREAD_OPEN conversationId=${event.roomId} '
      'type=${roomType?.name ?? 'unknown'} '
      'directSocketConnected=${_directMessaging.isConnected} '
      'groupSocketConnected=${_groupChat.isConnected}',
    );

    if (roomType == ChatRoomType.direct || _isDirectRoom(event.roomId)) {
      _directMessaging.ensureConnected();
      final cachedRoom = room ?? _roomById(event.roomId);
      if (cachedRoom != null) {
        _emitDirectMessageRead(cachedRoom, _messagesForRoom(event.roomId));
      }
      return;
    }

    if (roomType == ChatRoomType.group || _isGroupRoom(event.roomId)) {
      _groupChat.ensureConnected();
    }
  }

  void _onMessagingThreadClosed(
    ChatMessagingThreadClosed event,
    Emitter<ChatState> emit,
  ) {
    FaithLogger.d(
      _logTag,
      'THREAD_CLOSE conversationId=${event.roomId} '
      'type=${_roomById(event.roomId)?.type.name ?? 'unknown'}',
    );
    if (_openMessagingRoomId == event.roomId) {
      if (_isDirectRoom(event.roomId)) {
        _directMessaging.emitTypingStop(event.roomId);
      } else if (_isGroupRoom(event.roomId)) {
        _groupChat.emitTypingStop(event.roomId);
      }
      _openMessagingRoomId = null;
    }

    final current = state;
    if (current is ChatThreadLoaded && current.room.id == event.roomId) {
      emit(current.copyWith(clearPeerTyping: true));
    }
  }

  Future<void> _onThreadRequested(
    ChatThreadRequested event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    final sameThread = current is ChatThreadLoaded &&
        current.room.id == event.roomId;

    if (!event.silent && !sameThread) {
      emit(ChatThreadLoading(event.roomId));
    } else if (sameThread) {
      emit(current.copyWith(isRefreshing: true, clearSendError: true));
    }

    final roomResult = await _chatService.getRoom(event.roomId);
    final messagesResult = await _chatService.getMessages(event.roomId);
    final userId = await _resolveUserId();

    roomResult.fold(
      (failure) => emit(ChatFailureState(failure.message, roomId: event.roomId)),
      (room) {
        messagesResult.fold(
          (failure) {
            if (room.type == ChatRoomType.group) {
              _groupChat.ensureConnected();
              if (userId != null && _groupChat.isConnected) {
                _groupChat.emitPresenceOnline(userId: userId);
              }
              emit(
                ChatThreadLoaded(
                  room: room,
                  messages: const [],
                  isSocketConnected: _groupChat.isConnected,
                ),
              );
              return;
            }
            emit(ChatFailureState(failure.message, roomId: event.roomId));
          },
          (messages) {
            if (room.isDirect) {
              _directMessaging.ensureConnected();
              if (userId != null && _directMessaging.isConnected) {
                _directMessaging.emitPresenceOnline(userId: userId);
              }
              _emitDirectMessageRead(room, messages);
            } else if (room.isGroup) {
              _groupChat.ensureConnected();
              if (userId != null && _groupChat.isConnected) {
                _groupChat.emitPresenceOnline(userId: userId);
              }
              unawaited(_emitGroupMessageSeen(room, messages));
            }
            _emitThread(
              emit,
              ChatThreadLoaded(
                room: room,
                messages: messages,
                isSocketConnected: _isSocketConnectedForRoom(room),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatThreadLoaded || current.room.id != event.roomId) {
      return;
    }

    final trimmed = event.content.trim();
    final hasAttachment =
        event.attachmentPath != null && event.attachmentPath!.isNotEmpty;
    if ((trimmed.isEmpty && !hasAttachment) || current.isSending) return;

    final userId = await _resolveUserId();
    final pendingId = 'pending-${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: pendingId,
      roomId: event.roomId,
      senderId: userId ?? 'me',
      senderName: 'You',
      content: trimmed,
      createdAt: DateTime.now(),
      isMine: true,
      deliveryStatus: ChatMessageDeliveryStatus.sending,
      attachmentPath: event.attachmentPath,
      attachmentKind: event.attachmentKind,
      attachmentName: event.attachmentName,
    );

    _emitThread(
      emit,
      current.copyWith(
        messages: [...current.messages, optimistic],
        isSending: true,
        clearSendError: true,
        clearPeerTyping: true,
      ),
    );

    if (current.room.isDirect) {
      _directMessaging.emitTypingStop(event.roomId);
    } else if (current.room.isGroup) {
      _groupChat.emitTypingStop(event.roomId);
    }

    String? mediaUrl;
    if (hasAttachment) {
      final uploadResult = await _chatService.uploadAttachment(
        event.attachmentPath!,
        isGroup: current.room.isGroup,
      );
      uploadResult.fold(
        (failure) {
          emit(
            current.copyWith(
              messages: current.messages
                  .where((message) => message.id != pendingId)
                  .toList(),
              isSending: false,
              sendErrorMessage:
                  GroupAccessErrors.userFacingOrNull(failure.message),
            ),
          );
        },
        (url) {
          mediaUrl = url;
        },
      );
      if (mediaUrl == null) return;
    }

    if ((!hasAttachment && trimmed.isNotEmpty) || mediaUrl != null) {
      if (current.room.isDirect) {
        final sentViaSocket = await _trySendDirectViaSocket(
          room: current.room,
          messages: current.messages,
          body: trimmed,
          mediaUrl: mediaUrl,
        );
        if (sentViaSocket) {
          _finishSending(emit, event.roomId);
          return;
        }
        emit(
          current.copyWith(
            messages: current.messages
                .where((message) => message.id != pendingId)
                .toList(),
            isSending: false,
            sendErrorMessage:
                'Could not send message. Check your connection and try again.',
          ),
        );
        return;
      } else if (current.room.isGroup) {
        final sentViaSocket = await _trySendGroupViaSocket(
          groupId: current.room.id,
          body: trimmed,
          mediaUrl: mediaUrl,
        );
        if (sentViaSocket) {
          _finishSending(emit, event.roomId);
          return;
        }
        emit(
          current.copyWith(
            messages: current.messages
                .where((message) => message.id != pendingId)
                .toList(),
            isSending: false,
            sendErrorMessage:
                'Could not send message. Check your connection and try again.',
          ),
        );
        return;
      }
    }

    if (current.room.isGroup && trimmed.isEmpty && hasAttachment) {
      emit(
        current.copyWith(
          messages: current.messages
              .where((message) => message.id != pendingId)
              .toList(),
          isSending: false,
          sendErrorMessage: 'Group attachments are not supported yet.',
        ),
      );
      return;
    }

    final result = await _chatService.sendMessage(
      roomId: event.roomId,
      content: trimmed,
      attachmentPath: event.attachmentPath,
      attachmentName: event.attachmentName,
      attachmentKind: event.attachmentKind,
    );

    result.fold(
      (failure) {
        emit(
          current.copyWith(
            messages: current.messages,
            isSending: false,
            sendErrorMessage:
                GroupAccessErrors.userFacingOrNull(failure.message),
          ),
        );
      },
      (message) {
        final latest = state;
        if (latest is! ChatThreadLoaded || latest.room.id != event.roomId) {
          return;
        }
        if (latest.messages.any((m) => m.id == message.id)) {
          emit(
            latest.copyWith(
              messages: latest.messages.where((m) => m.id != pendingId).toList(),
              isSending: false,
              clearSendError: true,
            ),
          );
          return;
        }
        final withoutPending =
            latest.messages.where((m) => m.id != pendingId).toList();
        emit(
          latest.copyWith(
            messages: [...withoutPending, message],
            isSending: false,
            clearSendError: true,
          ),
        );
      },
    );
  }

  void _finishSending(Emitter<ChatState> emit, String roomId) {
    final latest = state;
    if (latest is ChatThreadLoaded && latest.room.id == roomId) {
      emit(latest.copyWith(isSending: false, clearSendError: true));
    }
  }

  bool _shouldUseRecipientId(ChatRoom room, List<ChatMessage> messages) {
    if (!room.isDirect) return false;
    final peer = room.peerUserId?.trim();
    if (peer == null || peer.isEmpty) return false;
    return room.id == peer;
  }

  List<ChatMessage> _messagesForRoom(String roomId) {
    final current = state;
    if (current is ChatThreadLoaded && current.room.id == roomId) {
      return current.messages;
    }
    return const [];
  }

  /// Real conversation UUID for direct socket events (`message:read`, reply, etc.).
  String? _directConversationId(ChatRoom room, List<ChatMessage> messages) {
    if (!room.isDirect || _shouldUseRecipientId(room, messages)) return null;
    return room.id;
  }

  void _emitDirectMessageRead(ChatRoom room, List<ChatMessage> messages) {
    final conversationId = _directConversationId(room, messages);
    if (conversationId == null) return;

    FaithLogger.d(
      _logTag,
      'DIRECT_READ message:read conversationId=$conversationId',
    );
    _directMessaging.ensureConnected();
    unawaited(_directMessaging.markConversationReadAsync(conversationId));
  }

  Future<void> _emitGroupMessageSeen(ChatRoom room, List<ChatMessage> messages) async {
    if (!room.isGroup) return;
    final userId = await _resolveUserId();
    if (userId == null) return;

    _groupChat.ensureConnected();
    for (final msg in messages) {
      if (msg.isMine || msg.senderId == userId) continue;
      final hasSeen = msg.seenReceipts.any((r) => r.userId == userId);
      if (!hasSeen) {
        _groupChat.markMessageSeen(groupId: room.id, messageId: msg.id);
      }
    }
  }

  String? _directTypingConversationId(
    ChatRoom room,
    List<ChatMessage> messages,
  ) {
    return _directConversationId(room, messages);
  }

  Future<bool> _trySendDirectViaSocket({
    required ChatRoom room,
    required List<ChatMessage> messages,
    required String body,
    String? mediaUrl,
  }) async {
    final useRecipientId = _shouldUseRecipientId(room, messages);
    FaithLogger.d(
      _logTag,
      'SEND_DIRECT message:send conversationId=${room.id} '
      'useRecipientId=$useRecipientId recipientId=${room.peerUserId} '
      'bodyLen=${body.length} mediaUrl=$mediaUrl',
    );

    final sent = await _directMessaging.sendMessageAsync(
      conversationId: useRecipientId ? null : room.id,
      recipientId: useRecipientId ? room.peerUserId : null,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!sent) {
      FaithLogger.w(
        _logTag,
        'SEND_DIRECT_FAILED conversationId=${room.id} '
        'socketConnected=${_directMessaging.isConnected}',
      );
      return false;
    }

    FaithLogger.d(
      _logTag,
      'SEND_DIRECT_EMITTED conversationId=${room.id} event=message:send',
    );
    return true;
  }

  Future<bool> _trySendGroupViaSocket({
    required String groupId,
    required String body,
    String? mediaUrl,
  }) async {
    FaithLogger.d(
      _logTag,
      'SEND_GROUP group:message:send groupId=$groupId bodyLen=${body.length} mediaUrl=$mediaUrl',
    );

    final sent = await _groupChat.sendMessageAsync(
      groupId: groupId,
      body: body,
      mediaUrl: mediaUrl,
    );
    if (!sent) {
      FaithLogger.w(
        _logTag,
        'SEND_GROUP_FAILED groupId=$groupId '
        'socketConnected=${_groupChat.isConnected}',
      );
      return false;
    }

    FaithLogger.d(
      _logTag,
      'SEND_GROUP_EMITTED groupId=$groupId event=group:message:send',
    );
    return true;
  }

  bool _isConversationOpen(String conversationId, {String? peerUserId}) {
    final openId = _openMessagingRoomId;
    if (openId == null) return false;
    if (openId == conversationId) return true;
    if (peerUserId != null && openId == peerUserId) return true;
    return false;
  }

  void _refreshInboxFromIncomingMessage(
    MessagingSocketMessage message,
    ChatMessage incoming, {
    required Emitter<ChatState> emit,
  }) {
    final conversationId = message.conversationId;
    if (conversationId.isEmpty) return;

    final isOpen = _isConversationOpen(
      conversationId,
      peerUserId: incoming.isMine ? null : incoming.senderId,
    );

    var index = _cachedRooms.indexWhere((room) {
      if (room.id == conversationId) return true;
      if (room.isDirect && !incoming.isMine) {
        final peer = room.peerUserId;
        if (peer != null && peer == incoming.senderId) return true;
        if (room.id == incoming.senderId) return true;
      }
      return false;
    });

    if (index < 0) return;

    final existing = _cachedRooms[index];
    final previewBody = incoming.content.trim().isNotEmpty
        ? incoming.content
        : (incoming.attachmentPath != null ? 'Media' : '');
    final senderName = incoming.isMine ? 'You' : incoming.senderName;
    final unread = (!isOpen && !incoming.isMine)
        ? existing.unreadCount + 1
        : existing.unreadCount;

    _cachedRooms[index] = existing.copyWith(
      id: existing.id != conversationId && existing.isDirect
          ? conversationId
          : existing.id,
      lastMessage: previewBody,
      lastSenderName: senderName,
      updatedAt: incoming.createdAt,
      unreadCount: unread,
      hasUnreadDot: unread > 0 || (!isOpen && !incoming.isMine),
    );

    _cachedRooms.sort(
      (a, b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );

    final current = state;
    if (current is ChatRoomsLoaded) {
      emit(current.copyWith(rooms: List<ChatRoom>.from(_cachedRooms)));
    }
  }

  Future<void> _onIncomingMessage(
    ChatIncomingMessageReceived event,
    Emitter<ChatState> emit,
  ) async {
    final userId = await _resolveUserId();
    final message = event.message;
    var incoming = message.toChatMessage(currentUserId: userId);

    _refreshInboxFromIncomingMessage(message, incoming, emit: emit);

    final current = state;
    if (current is! ChatThreadLoaded) return;

    final matchesThread = current.room.id == message.conversationId ||
        (_shouldUseRecipientId(current.room, current.messages) &&
            current.room.isDirect);

    if (!matchesThread) {
      FaithLogger.d(
        _logTag,
        'INCOMING_IGNORED socketConversationId=${message.conversationId} '
        'activeConversationId=${current.room.id}',
      );
      return;
    }

    var room = current.room;
    if (room.isDirect) {
      final peerId = room.peerUserId?.trim();
      if (peerId != null && peerId.isNotEmpty) {
        final isPeer = incoming.senderId == peerId;
        incoming = incoming.copyWith(
          isMine: !isPeer,
          senderName: !isPeer ? 'You' : incoming.senderName,
        );
      }
    }

    if (current.messages.any((m) => m.id == incoming.id)) {
      FaithLogger.d(
        _logTag,
        'INCOMING_DUPLICATE conversationId=${message.conversationId} '
        'messageId=${incoming.id}',
      );
      return;
    }

    var messages = List<ChatMessage>.from(current.messages);

    if (incoming.isMine) {
      final incomingReplyId = incoming.replyToId?.trim();
      final idx = messages.indexWhere((m) {
        if (!m.id.startsWith('pending-')) return false;
        if (m.content.trim() != incoming.content.trim()) return false;
        if (incomingReplyId != null && incomingReplyId.isNotEmpty) {
          return m.replyToId?.trim() == incomingReplyId;
        }
        return m.replyToId == null || m.replyToId!.trim().isEmpty;
      });
      if (idx != -1) {
        messages.removeAt(idx);
      } else {
        final fallbackIdx = messages.indexWhere((m) => m.id.startsWith('pending-'));
        if (fallbackIdx != -1) {
          messages.removeAt(fallbackIdx);
        }
      }
    }

    if (room.isDirect &&
        message.conversationId.isNotEmpty &&
        room.id != message.conversationId &&
        _shouldUseRecipientId(room, current.messages)) {
      FaithLogger.i(
        _logTag,
        'CONVERSATION_ID_RESOLVED from=${room.id} '
        'to=${message.conversationId}',
      );
      room = room.copyWith(id: message.conversationId);
      _cachedRooms = _cachedRooms
          .map(
            (cached) => cached.id == _openMessagingRoomId ||
                    cached.peerUserId == room.peerUserId
                ? cached.copyWith(id: message.conversationId)
                : cached,
          )
          .toList();
      if (room.isDirect) {
        _emitDirectMessageRead(room, messages);
      } else if (room.isGroup) {
        unawaited(_emitGroupMessageSeen(room, messages));
      }
    }

    FaithLogger.d(
      _logTag,
      'INCOMING_APPLIED conversationId=${room.id} messageId=${incoming.id} '
      'senderId=${incoming.senderId} isMine=${incoming.isMine}',
    );
    incoming = incoming.copyWith(
      replyToId: message.replyToId,
      deliveryStatus: incoming.isMine
          ? ChatMessageDeliveryStatus.sent
          : incoming.deliveryStatus,
    );
    messages.add(incoming);
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _emitThread(
      emit,
      current.copyWith(
        room: room,
        messages: messages,
        isSending: false,
        clearSendError: true,
        clearPeerTyping: !incoming.isMine,
      ),
    );
  }

  Future<void> _onMessageUpdated(
    ChatMessageUpdatedReceived event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatThreadLoaded) return;
    if (current.room.id != event.message.conversationId) return;

    final userId = await _resolveUserId();
    final updated = event.message.toChatMessage(currentUserId: userId);

    final messages = current.messages.map((message) {
      return message.id == updated.id ? updated : message;
    }).toList();

    _emitThread(emit, current.copyWith(messages: messages));
  }

  void _onMessageDeleted(
    ChatMessageDeletedReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatThreadLoaded) return;

    final payload = event.payload;
    if (payload.conversationId != null &&
        payload.conversationId!.isNotEmpty &&
        payload.conversationId != current.room.id) {
      return;
    }

    final messages = current.messages
        .where((message) => message.id != payload.messageId)
        .toList();

    _emitThread(emit, current.copyWith(messages: messages));
  }

  void _onConversationRead(
    ChatConversationReadUpdated event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatThreadLoaded) return;
    if (current.room.id != event.payload.conversationId) return;

    FaithLogger.d(
      _logTag,
      'CONVERSATION_READ conversationId=${event.payload.conversationId} '
      'readBy=${event.payload.readBy}',
    );

    final updatedMessages = current.messages.map((m) {
      if (m.isMine && m.deliveryStatus != ChatMessageDeliveryStatus.read) {
        return m.copyWith(deliveryStatus: ChatMessageDeliveryStatus.read);
      }
      return m;
    }).toList();

    _emitThread(
      emit,
      current.copyWith(
        messages: updatedMessages,
        lastReadByUserId: event.payload.readBy,
        clearPeerTyping: true,
      ),
    );
  }

  void _onGroupMessageSeen(
    ChatGroupMessageSeen event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatThreadLoaded) return;
    if (current.room.id != event.payload.groupId) return;

    final messageId = event.payload.messageId;
    final messages = List<ChatMessage>.from(current.messages);
    final index = messages.indexWhere((m) => m.id == messageId);

    if (index != -1) {
      final msg = messages[index];
      
      final seenReceipt = ChatMessageSeenReceipt(
        userId: event.payload.userId,
        fullName: event.payload.seenBy['fullName']?.toString() ??
            event.payload.seenBy['name']?.toString() ??
            'Unknown',
        avatarUrl: event.payload.seenBy['avatarUrl']?.toString() ??
            event.payload.seenBy['avatar_url']?.toString(),
        seenAt: event.payload.seenAt,
      );

      final existingReceipts = List<ChatMessageSeenReceipt>.from(msg.seenReceipts);
      final hasSeen = existingReceipts.any((r) => r.userId == seenReceipt.userId);
      
      if (!hasSeen) {
        existingReceipts.add(seenReceipt);
        messages[index] = msg.copyWith(
          seenReceipts: existingReceipts,
          deliveryStatus: ChatMessageDeliveryStatus.read,
        );
        _emitThread(emit, current.copyWith(messages: messages));
      }
    }
  }

  Future<void> _onMessageSeenByMe(
    ChatMessageSeenByMe event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatThreadLoaded) return;
    if (current.room.id != event.roomId) return;

    if (current.room.isDirect) {
      _emitDirectMessageRead(current.room, current.messages);
      return;
    }

    if (!current.room.isGroup) return;

    final userId = await _resolveUserId();
    if (userId == null) return;

    final message = _findMessage(current.messages, event.messageId);
    if (message == null || message.isMine || message.senderId == userId) return;

    final hasSeen = message.seenReceipts.any((r) => r.userId == userId);
    if (!hasSeen) {
      _groupChat.markMessageSeen(groupId: event.roomId, messageId: event.messageId);
    }
  }

  Future<void> _onPeerTypingChanged(
    ChatPeerTypingChanged event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatThreadLoaded) return;

    final matchesThread = current.room.id == event.conversationId ||
        (current.room.isDirect &&
            _shouldUseRecipientId(current.room, current.messages) &&
            _openMessagingRoomId == current.room.id);

    if (!matchesThread) return;

    final userId = await _resolveUserId();
    final peerId = event.userId;
    if (peerId != null &&
        userId != null &&
        peerId.isNotEmpty &&
        peerId == userId) {
      return;
    }

    if (current.room.isDirect) {
      if (!event.isTyping || peerId == null || peerId.isEmpty) {
        emit(current.copyWith(clearPeerTyping: true));
      } else {
        emit(current.copyWith(isPeerTyping: true));
      }
    } else if (current.room.isGroup) {
      if (peerId == null || peerId.isEmpty) return; // Need a userId to track in group

      final typingUserIds = Set<String>.from(current.typingUserIds);
      if (event.isTyping) {
        typingUserIds.add(peerId);
      } else {
        typingUserIds.remove(peerId);
      }
      
      emit(current.copyWith(
        typingUserIds: typingUserIds,
        isPeerTyping: typingUserIds.isNotEmpty,
      ));
    }
  }

  void _onTypingStarted(
    ChatTypingStarted event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is ChatThreadLoaded && current.room.id == event.roomId) {
      if (current.room.isDirect) {
        _directMessaging.ensureConnected();
        final conversationId = _directTypingConversationId(
          current.room,
          current.messages,
        );
        if (conversationId != null) {
          _directMessaging.emitTypingStart(conversationId);
        }
        return;
      }
      if (current.room.isGroup) {
        _groupChat.ensureConnected();
        _groupChat.emitTypingStart(event.roomId);
        return;
      }
    }

    if (_isDirectRoom(event.roomId)) {
      _directMessaging.ensureConnected();
      _directMessaging.emitTypingStart(event.roomId);
      return;
    }
    if (_isGroupRoom(event.roomId)) {
      _groupChat.ensureConnected();
      _groupChat.emitTypingStart(event.roomId);
    }
  }

  void _onTypingStopped(
    ChatTypingStopped event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is ChatThreadLoaded && current.room.id == event.roomId) {
      if (current.room.isDirect) {
        final conversationId = _directTypingConversationId(
          current.room,
          current.messages,
        );
        if (conversationId != null) {
          _directMessaging.emitTypingStop(conversationId);
        }
        return;
      }
      if (current.room.isGroup) {
        _groupChat.emitTypingStop(event.roomId);
        return;
      }
    }

    if (_isDirectRoom(event.roomId)) {
      _directMessaging.emitTypingStop(event.roomId);
      return;
    }
    if (_isGroupRoom(event.roomId)) {
      _groupChat.emitTypingStop(event.roomId);
    }
  }

  Future<void> _onLegacyDirectReplySent(
    ChatDirectReplySent event,
    Emitter<ChatState> emit,
  ) async {
    await _onReplySent(
      ChatReplySent(
        roomId: event.roomId,
        replyToId: event.replyToId,
        content: event.content,
      ),
      emit,
    );
  }

  Future<void> _onReplySent(
    ChatReplySent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatThreadLoaded || current.room.id != event.roomId) {
      return;
    }

    final trimmed = event.content.trim();
    final hasAttachment = event.attachmentPath != null && event.attachmentPath!.isNotEmpty;
    if ((trimmed.isEmpty && !hasAttachment) || current.isSending) return;

    final userId = await _resolveUserId();
    final pendingId = 'pending-${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: pendingId,
      roomId: event.roomId,
      senderId: userId ?? 'me',
      senderName: 'You',
      content: trimmed,
      createdAt: DateTime.now(),
      isMine: true,
      replyToId: event.replyToId,
      replyPreview: _replyPreviewFor(current.messages, event.replyToId),
      deliveryStatus: ChatMessageDeliveryStatus.sending,
      attachmentPath: event.attachmentPath,
      attachmentKind: event.attachmentKind,
      attachmentName: event.attachmentName,
    );

    _emitThread(
      emit,
      current.copyWith(
        messages: [...current.messages, optimistic],
        isSending: true,
        clearSendError: true,
        clearPeerTyping: true,
      ),
    );

    if (current.room.isDirect) {
      _directMessaging.emitTypingStop(event.roomId);
    } else if (current.room.isGroup) {
      _groupChat.emitTypingStop(event.roomId);
    }

    String? mediaUrl;
    if (hasAttachment) {
      final uploadResult = await _chatService.uploadAttachment(
        event.attachmentPath!,
        isGroup: current.room.isGroup,
      );
      uploadResult.fold(
        (failure) {
          emit(
            current.copyWith(
              messages: current.messages
                  .where((message) => message.id != pendingId)
                  .toList(),
              isSending: false,
              sendErrorMessage: GroupAccessErrors.userFacingOrNull(failure.message),
            ),
          );
        },
        (url) {
          mediaUrl = url;
        },
      );
      if (mediaUrl == null) return;
    }

    if ((!hasAttachment && trimmed.isNotEmpty) || mediaUrl != null) {
      if (current.room.isDirect) {
        final conversationId = _directConversationId(current.room, current.messages);
        if (conversationId == null) {
          _finishSending(emit, event.roomId);
          return;
        }

        FaithLogger.d(
          _logTag,
          'DIRECT_REPLY message:reply conversationId=$conversationId '
          'replyToId=${event.replyToId} mediaUrl=$mediaUrl',
        );
        final sent = await _directMessaging.sendReplyAsync(
          conversationId: conversationId,
          replyToId: event.replyToId,
          body: trimmed,
          mediaUrl: mediaUrl,
        );
        if (!sent) {
          final latest = state;
          if (latest is ChatThreadLoaded && latest.room.id == event.roomId) {
            emit(
              latest.copyWith(
                messages: latest.messages
                    .where((message) => message.id != pendingId)
                    .toList(),
                isSending: false,
                sendErrorMessage:
                    'Could not send reply. Check your connection and try again.',
              ),
            );
          }
          return;
        }
      } else if (current.room.isGroup) {
        FaithLogger.d(
          _logTag,
          'GROUP_REPLY group:message:reply groupId=${current.room.id} '
          'replyToId=${event.replyToId} mediaUrl=$mediaUrl',
        );
        final sent = await _groupChat.sendReplyAsync(
          groupId: current.room.id,
          parentId: event.replyToId,
          body: trimmed,
          mediaUrl: mediaUrl,
        );
        if (!sent) {
          final latest = state;
          if (latest is ChatThreadLoaded && latest.room.id == event.roomId) {
            emit(
              latest.copyWith(
                messages: latest.messages
                    .where((message) => message.id != pendingId)
                    .toList(),
                isSending: false,
                sendErrorMessage:
                    'Could not send reply. Check your connection and try again.',
              ),
            );
          }
          return;
        }
      }

      _finishSending(emit, event.roomId);
    }
  }

  Future<void> _onLegacyDirectMessageUpdated(
    ChatDirectMessageUpdated event,
    Emitter<ChatState> emit,
  ) async {
    await _onMessageEditSent(
      ChatMessageEditSent(
        roomId: event.roomId,
        messageId: event.messageId,
        content: event.content,
      ),
      emit,
    );
  }

  Future<void> _onLegacyDirectMessageDeleted(
    ChatDirectMessageDeleted event,
    Emitter<ChatState> emit,
  ) async {
    await _onMessageDeleteSent(
      ChatMessageDeleteSent(
        roomId: event.roomId,
        messageId: event.messageId,
      ),
      emit,
    );
  }

  Future<void> _onMessageEditSent(
    ChatMessageEditSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatThreadLoaded || current.room.id != event.roomId) {
      return;
    }

    final trimmed = event.content.trim();
    if (trimmed.isEmpty) return;

    final original = _findMessage(current.messages, event.messageId);
    if (original == null || !original.isMine) return;

    final optimistic = current.messages
        .map(
          (message) => message.id == event.messageId
              ? message.copyWith(content: trimmed)
              : message,
        )
        .toList();

    _emitThread(emit, current.copyWith(messages: optimistic, clearSendError: true));

    final bool sent;
    if (current.room.isDirect) {
      FaithLogger.d(
        _logTag,
        'DIRECT_UPDATE message:update messageId=${event.messageId}',
      );
      sent = await _directMessaging.updateMessageAsync(
        messageId: event.messageId,
        body: trimmed,
      );
    } else if (current.room.isGroup) {
      FaithLogger.d(
        _logTag,
        'GROUP_UPDATE group:message:update groupId=${current.room.id} '
        'messageId=${event.messageId}',
      );
      sent = await _groupChat.updateMessageAsync(
        groupId: current.room.id,
        messageId: event.messageId,
        body: trimmed,
      );
    } else {
      return;
    }

    if (sent) return;

    final latest = state;
    if (latest is! ChatThreadLoaded || latest.room.id != event.roomId) return;

    final rolledBack = latest.messages
        .map(
          (message) =>
              message.id == event.messageId ? original : message,
        )
        .toList();

    _emitThread(
      emit,
      latest.copyWith(
        messages: rolledBack,
        sendErrorMessage: 'Could not update message. Please try again.',
      ),
    );
  }

  Future<void> _onMessageDeleteSent(
    ChatMessageDeleteSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatThreadLoaded || current.room.id != event.roomId) {
      return;
    }

    final original = _findMessage(current.messages, event.messageId);
    if (original == null || !original.isMine) return;

    final optimistic = current.messages
        .where((message) => message.id != event.messageId)
        .toList();

    _emitThread(emit, current.copyWith(messages: optimistic, clearSendError: true));

    final bool sent;
    if (current.room.isDirect) {
      FaithLogger.d(
        _logTag,
        'DIRECT_DELETE message:delete messageId=${event.messageId}',
      );
      sent = await _directMessaging.deleteMessageAsync(
        messageId: event.messageId,
      );
    } else if (current.room.isGroup) {
      FaithLogger.d(
        _logTag,
        'GROUP_DELETE group:message:delete groupId=${current.room.id} '
        'messageId=${event.messageId}',
      );
      final result = await _chatService.deleteMessage(
        roomId: current.room.id,
        messageId: event.messageId,
      );
      sent = result.isRight();
    } else {
      return;
    }

    if (sent) return;

    final latest = state;
    if (latest is! ChatThreadLoaded || latest.room.id != event.roomId) return;

    final index = current.messages.indexWhere(
      (message) => message.id == event.messageId,
    );
    final restored = List<ChatMessage>.from(latest.messages);
    if (index >= 0) {
      restored.insert(index.clamp(0, restored.length), original);
    } else {
      restored.add(original);
    }

    _emitThread(
      emit,
      latest.copyWith(
        messages: restored,
        sendErrorMessage: 'Could not delete message. Please try again.',
      ),
    );
  }

  void _onSendErrorDismissed(
    ChatSendErrorDismissed event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is ChatThreadLoaded) {
      emit(current.copyWith(clearSendError: true));
    }
  }

  void _onSocketConnectionChanged(
    ChatSocketConnectionChanged event,
    Emitter<ChatState> emit,
  ) {
    if (event.isConnected && _currentUserId != null) {
      if (event.namespace == SocketNamespace.messaging) {
        _directMessaging.emitPresenceOnline(userId: _currentUserId!);
      } else if (event.namespace == SocketNamespace.groups) {
        _groupChat.emitPresenceOnline(userId: _currentUserId!);
      }
    }

    if (event.isConnected &&
        (event.namespace == SocketNamespace.messaging ||
            event.namespace == SocketNamespace.groups)) {
      final shouldRefresh = switch (event.namespace) {
        SocketNamespace.messaging => _messagingSocketWasDisconnected,
        SocketNamespace.groups => _groupsSocketWasDisconnected,
        _ => false,
      };
      if (shouldRefresh) {
        if (event.namespace == SocketNamespace.messaging) {
          _messagingSocketWasDisconnected = false;
        } else if (event.namespace == SocketNamespace.groups) {
          _groupsSocketWasDisconnected = false;
        }
        final inbox = state;
        if (inbox is ChatRoomsLoaded) {
          add(const ChatRoomsRefreshed());
        }
      }
    } else if (!event.isConnected) {
      if (event.namespace == SocketNamespace.messaging) {
        _messagingSocketWasDisconnected = true;
      } else if (event.namespace == SocketNamespace.groups) {
        _groupsSocketWasDisconnected = true;
      }
    }

    final current = state;
    if (current is! ChatThreadLoaded) return;

    final matchesDirect = current.room.isDirect &&
        event.namespace == SocketNamespace.messaging;
    final matchesGroup = current.room.isGroup &&
        event.namespace == SocketNamespace.groups;
    if (!matchesDirect && !matchesGroup) return;

    if (current.isSocketConnected == event.isConnected) return;

    FaithLogger.d(
      _logTag,
      'SOCKET_STATUS conversationId=${current.room.id} '
      'namespace=${event.namespace} connected=${event.isConnected}',
    );
    emit(current.copyWith(isSocketConnected: event.isConnected));
  }

  void _onPresenceStatusChanged(
    ChatPresenceStatusChanged event,
    Emitter<ChatState> emit,
  ) {
    final payload = event.payload;

    // Update cached rooms (Inbox list)
    _cachedRooms = _cachedRooms.map((room) {
      if (room.isDirect && room.peerUserId == payload.userId) {
        return room.copyWith(
          isOnline: payload.isOnline,
          statusSubtitle: payload.isOnline ? 'Online' : 'Offline',
        );
      }
      return room;
    }).toList();

    final current = state;
    if (current is ChatRoomsLoaded) {
      emit(current.copyWith(rooms: _cachedRooms));
    } else if (current is ChatThreadLoaded) {
      if (current.room.isDirect && current.room.peerUserId == payload.userId) {
        emit(current.copyWith(
          room: current.room.copyWith(
            isOnline: payload.isOnline,
            statusSubtitle: payload.isOnline ? 'Online' : 'Offline',
          ),
        ));
      }
    }
  }

  Future<void> _onUserBlockRequested(
    ChatUserBlockRequested event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _chatService.blockUser(event.userId);
    result.fold(
      (failure) {
        final current = state;
        if (current is ChatThreadLoaded) {
          emit(current.copyWith(sendErrorMessage: failure.message));
        }
      },
      (_) {
        // Success block
      },
    );
  }

  Future<void> _onUserUnblockRequested(
    ChatUserUnblockRequested event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _chatService.unblockUser(event.userId);
    result.fold(
      (failure) {
        final current = state;
        if (current is ChatThreadLoaded) {
          emit(current.copyWith(sendErrorMessage: failure.message));
        }
      },
      (_) {
        // Success unblock
      },
    );
  }
}
