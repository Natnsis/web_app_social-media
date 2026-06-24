import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.roomId,
    required super.senderId,
    required super.senderName,
    super.senderAvatarUrl,
    required super.content,
    required super.createdAt,
    super.isMine,
    super.isModerator,
    super.attachmentPath,
    super.attachmentKind,
    super.attachmentName,
    super.replyToId,
    super.replyPreview,
    super.deliveryStatus,
    super.seenReceipts,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderName: json['sender_name'] as String? ?? '',
      senderAvatarUrl: json['sender_avatar_url'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isMine: json['is_mine'] as bool? ?? false,
      isModerator: json['is_moderator'] as bool? ?? false,
    );
  }

  ChatMessage toEntity() => ChatMessage(
        id: id,
        roomId: roomId,
        senderId: senderId,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
        content: content,
        createdAt: createdAt,
        isMine: isMine,
        isModerator: isModerator,
        attachmentPath: attachmentPath,
        attachmentKind: attachmentKind,
        attachmentName: attachmentName,
        replyToId: replyToId,
        replyPreview: replyPreview,
        deliveryStatus: deliveryStatus,
        seenReceipts: seenReceipts,
      );
}
