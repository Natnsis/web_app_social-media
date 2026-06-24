import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/services/socket/messaging_socket_payloads.dart'
    show ConversationReadPayload, MessageDeletedPayload, MessagingSocketMessage, PresencePayload;
import 'package:faithconnect/core/services/socket/group_chat_socket_payloads.dart'
    show GroupMessageSeenPayload;
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatRoomsRequested extends ChatEvent {
  const ChatRoomsRequested();
}

/// Reload inbox without clearing the current list (pull-to-refresh).
final class ChatRoomsRefreshed extends ChatEvent {
  const ChatRoomsRefreshed();
}

/// Restores the inbox list from cache when leaving a thread (e.g. back from detail).
final class ChatListRestoreRequested extends ChatEvent {
  final ChatRoomType? inboxTab;

  const ChatListRestoreRequested({this.inboxTab});

  @override
  List<Object?> get props => [inboxTab];
}

/// Caches a placeholder direct room when starting a chat with a new user.
final class ChatDirectRoomPrepared extends ChatEvent {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  const ChatDirectRoomPrepared({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, displayName, avatarUrl];
}

final class ChatSocketConnectionChanged extends ChatEvent {
  final String namespace;
  final bool isConnected;

  const ChatSocketConnectionChanged({
    required this.namespace,
    required this.isConnected,
  });

  @override
  List<Object?> get props => [namespace, isConnected];
}

final class ChatThreadRequested extends ChatEvent {
  final String roomId;
  final bool silent;

  const ChatThreadRequested(this.roomId, {this.silent = false});

  @override
  List<Object?> get props => [roomId, silent];
}

final class ChatMessageSent extends ChatEvent {
  final String roomId;
  final String content;
  final String? attachmentPath;
  final String? attachmentName;
  final MediaUploadKind? attachmentKind;

  const ChatMessageSent({
    required this.roomId,
    required this.content,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentKind,
  });

  @override
  List<Object?> get props => [
        roomId,
        content,
        attachmentPath,
        attachmentName,
        attachmentKind,
      ];
}

final class ChatSendErrorDismissed extends ChatEvent {
  const ChatSendErrorDismissed();
}

/// Connect messaging socket and prepare the open thread.
final class ChatMessagingThreadOpened extends ChatEvent {
  final String roomId;
  final ChatRoomType? roomType;

  const ChatMessagingThreadOpened(this.roomId, {this.roomType});

  @override
  List<Object?> get props => [roomId, roomType];
}

/// Leave thread — stops typing indicators for this conversation.
final class ChatMessagingThreadClosed extends ChatEvent {
  final String roomId;

  const ChatMessagingThreadClosed(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

final class ChatIncomingMessageReceived extends ChatEvent {
  final MessagingSocketMessage message;

  const ChatIncomingMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

final class ChatMessageUpdatedReceived extends ChatEvent {
  final MessagingSocketMessage message;

  const ChatMessageUpdatedReceived(this.message);

  @override
  List<Object?> get props => [message];
}

final class ChatMessageDeletedReceived extends ChatEvent {
  final MessageDeletedPayload payload;

  const ChatMessageDeletedReceived(this.payload);

  @override
  List<Object?> get props => [payload];
}

final class ChatConversationReadUpdated extends ChatEvent {
  final ConversationReadPayload payload;

  const ChatConversationReadUpdated(this.payload);

  @override
  List<Object?> get props => [payload];
}

final class ChatPeerTypingChanged extends ChatEvent {
  final String conversationId;
  final String? userId;
  final bool isTyping;

  const ChatPeerTypingChanged({
    required this.conversationId,
    required this.isTyping,
    this.userId,
  });

  @override
  List<Object?> get props => [conversationId, userId, isTyping];
}

final class ChatTypingStarted extends ChatEvent {
  final String roomId;

  const ChatTypingStarted(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

final class ChatTypingStopped extends ChatEvent {
  final String roomId;

  const ChatTypingStopped(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// Reply to a message — direct (`message:reply`) or group (`group:message:reply`).
final class ChatReplySent extends ChatEvent {
  final String roomId;
  final String replyToId;
  final String content;
  final String? attachmentPath;
  final MediaUploadKind? attachmentKind;
  final String? attachmentName;

  const ChatReplySent({
    required this.roomId,
    required this.replyToId,
    required this.content,
    this.attachmentPath,
    this.attachmentKind,
    this.attachmentName,
  });

  @override
  List<Object?> get props => [
        roomId,
        replyToId,
        content,
        attachmentPath,
        attachmentKind,
        attachmentName,
      ];
}

/// Direct socket — `message:reply` `{ conversationId, replyToId, body }`.
final class ChatDirectReplySent extends ChatEvent {
  final String roomId;
  final String replyToId;
  final String content;

  const ChatDirectReplySent({
    required this.roomId,
    required this.replyToId,
    required this.content,
  });

  @override
  List<Object?> get props => [roomId, replyToId, content];
}

/// Edit a message — direct (`message:update`) or group (`group:message:update`).
final class ChatMessageEditSent extends ChatEvent {
  final String roomId;
  final String messageId;
  final String content;

  const ChatMessageEditSent({
    required this.roomId,
    required this.messageId,
    required this.content,
  });

  @override
  List<Object?> get props => [roomId, messageId, content];
}

/// Delete a message — direct (`message:delete`) or group (`group:message:delete`).
final class ChatMessageDeleteSent extends ChatEvent {
  final String roomId;
  final String messageId;

  const ChatMessageDeleteSent({
    required this.roomId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [roomId, messageId];
}

/// Direct socket — `message:update` `{ messageId, body }`.
final class ChatDirectMessageUpdated extends ChatEvent {
  final String roomId;
  final String messageId;
  final String content;

  const ChatDirectMessageUpdated({
    required this.roomId,
    required this.messageId,
    required this.content,
  });

  @override
  List<Object?> get props => [roomId, messageId, content];
}

/// Direct socket — `message:delete` `{ messageId }`.
final class ChatDirectMessageDeleted extends ChatEvent {
  final String roomId;
  final String messageId;

  const ChatDirectMessageDeleted({
    required this.roomId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [roomId, messageId];
}

/// Socket event — `presence:online` / `presence:offline`.
class ChatPresenceStatusChanged extends ChatEvent {
  final PresencePayload payload;

  const ChatPresenceStatusChanged(this.payload);

  @override
  List<Object?> get props => [payload];
}

/// Socket event - `group:message:seen`.
class ChatGroupMessageSeen extends ChatEvent {
  final GroupMessageSeenPayload payload;

  const ChatGroupMessageSeen(this.payload);

  @override
  List<Object?> get props => [payload];
}

class ChatMessageSeenByMe extends ChatEvent {
  final String roomId;
  final String messageId;

  const ChatMessageSeenByMe({
    required this.roomId,
    required this.messageId,
  });

  @override
  List<Object?> get props => [roomId, messageId];
}

final class ChatUserBlockRequested extends ChatEvent {
  final String userId;

  const ChatUserBlockRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final class ChatUserUnblockRequested extends ChatEvent {
  final String userId;

  const ChatUserUnblockRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
