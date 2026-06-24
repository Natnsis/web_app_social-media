import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_delivery_status.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_reply_preview.dart';

class ChatMessageSeenReceipt extends Equatable {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final DateTime seenAt;

  const ChatMessageSeenReceipt({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.seenAt,
  });

  @override
  List<Object?> get props => [userId, fullName, avatarUrl, seenAt];
}

class ChatMessage extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final DateTime createdAt;
  final bool isMine;
  final bool isModerator;
  final String? attachmentPath;
  final MediaUploadKind? attachmentKind;
  final String? attachmentName;
  final String? replyToId;
  final ChatMessageReplyPreview? replyPreview;
  final ChatMessageDeliveryStatus deliveryStatus;
  final List<ChatMessageSeenReceipt> seenReceipts;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.createdAt,
    this.isMine = false,
    this.isModerator = false,
    this.attachmentPath,
    this.attachmentKind,
    this.attachmentName,
    this.replyToId,
    this.replyPreview,
    this.deliveryStatus = ChatMessageDeliveryStatus.sent,
    this.seenReceipts = const [],
  });

  bool get isReply => replyToId != null && replyToId!.isNotEmpty;

  bool get hasAttachment =>
      attachmentPath != null && attachmentPath!.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    DateTime? createdAt,
    bool? isMine,
    bool? isModerator,
    String? attachmentPath,
    MediaUploadKind? attachmentKind,
    String? attachmentName,
    String? replyToId,
    ChatMessageReplyPreview? replyPreview,
    ChatMessageDeliveryStatus? deliveryStatus,
    List<ChatMessageSeenReceipt>? seenReceipts,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      isModerator: isModerator ?? this.isModerator,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentKind: attachmentKind ?? this.attachmentKind,
      attachmentName: attachmentName ?? this.attachmentName,
      replyToId: replyToId ?? this.replyToId,
      replyPreview: replyPreview ?? this.replyPreview,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      seenReceipts: seenReceipts ?? this.seenReceipts,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderId,
        senderName,
        senderAvatarUrl,
        content,
        createdAt,
        isMine,
        isModerator,
        attachmentPath,
        attachmentKind,
        attachmentName,
        replyToId,
        replyPreview,
        deliveryStatus,
        seenReceipts,
      ];
}
