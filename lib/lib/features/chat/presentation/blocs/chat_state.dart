import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatListLoading extends ChatState {
  const ChatListLoading();
}

final class ChatThreadLoading extends ChatState {
  final String roomId;

  const ChatThreadLoading(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

final class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> rooms;
  final ChatRoomType? restoreInboxTab;

  const ChatRoomsLoaded(this.rooms, {this.restoreInboxTab});

  ChatRoomsLoaded copyWith({
    List<ChatRoom>? rooms,
    ChatRoomType? restoreInboxTab,
  }) {
    return ChatRoomsLoaded(
      rooms ?? this.rooms,
      restoreInboxTab: restoreInboxTab ?? this.restoreInboxTab,
    );
  }

  @override
  List<Object?> get props => [rooms, restoreInboxTab];
}

final class ChatThreadLoaded extends ChatState {
  final ChatRoom room;
  final List<ChatMessage> messages;
  final bool isSending;
  final bool isRefreshing;
  final String? sendErrorMessage;
  final bool isPeerTyping;
  final Set<String> typingUserIds;
  final String? lastReadByUserId;
  final bool isSocketConnected;

  const ChatThreadLoaded({
    required this.room,
    required this.messages,
    this.isSending = false,
    this.isRefreshing = false,
    this.sendErrorMessage,
    this.isPeerTyping = false,
    this.typingUserIds = const {},
    this.lastReadByUserId,
    this.isSocketConnected = true,
  });

  ChatThreadLoaded copyWith({
    ChatRoom? room,
    List<ChatMessage>? messages,
    bool? isSending,
    bool? isRefreshing,
    String? sendErrorMessage,
    bool? isPeerTyping,
    Set<String>? typingUserIds,
    String? lastReadByUserId,
    bool? isSocketConnected,
    bool clearSendError = false,
    bool clearPeerTyping = false,
    bool clearReadReceipt = false,
  }) {
    return ChatThreadLoaded(
      room: room ?? this.room,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      sendErrorMessage:
          clearSendError ? null : (sendErrorMessage ?? this.sendErrorMessage),
      isPeerTyping: clearPeerTyping ? false : (isPeerTyping ?? this.isPeerTyping),
      typingUserIds: clearPeerTyping ? const {} : (typingUserIds ?? this.typingUserIds),
      lastReadByUserId: clearReadReceipt
          ? null
          : (lastReadByUserId ?? this.lastReadByUserId),
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
    );
  }

  @override
  List<Object?> get props => [
        room,
        messages,
        isSending,
        isRefreshing,
        sendErrorMessage,
        isPeerTyping,
        typingUserIds,
        lastReadByUserId,
        isSocketConnected,
      ];
}

final class ChatFailureState extends ChatState {
  final String message;
  final String? roomId;

  const ChatFailureState(this.message, {this.roomId});

  @override
  List<Object?> get props => [message, roomId];
}
