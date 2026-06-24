import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_delivery_status.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_reply_preview.dart';
import 'package:faithconnect/features/chat/data/models/chat_message_model.dart';
import 'package:faithconnect/features/comment/data/dto/comment_api_dto.dart';

abstract final class GroupMessageMapper {
  GroupMessageMapper._();

  static ChatMessageModel fromCommentDto(
    CommentApiDto dto, {
    required String roomId,
    String? currentUserId,
  }) {
    final isMine = dto.isOwnedByMe ||
        (currentUserId != null && dto.authorId == currentUserId);

    ChatMessageReplyPreview? replyPreview;
    if (dto.parentId != null && dto.parentId!.isNotEmpty) {
      replyPreview = ChatMessageReplyPreview(
        messageId: dto.parentId!,
        content: 'Reply to message', // Group messages don't always include the parent body in the flat DTO
        senderName: 'Member',
        isOriginalMine: false,
      );
    }

    final receipts = dto.reads.map((r) {
      final user = r['user'] as Map<String, dynamic>? ?? {};
      return ChatMessageSeenReceipt(
        userId: user['id']?.toString() ?? '',
        fullName: user['fullName']?.toString() ??
            user['name']?.toString() ??
            'Unknown',
        avatarUrl: user['avatarUrl']?.toString() ?? user['avatar_url']?.toString(),
        seenAt: DateTime.tryParse(r['seenAt']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList();

    final deliveryStatus = receipts.isNotEmpty
        ? ChatMessageDeliveryStatus.read
        : ChatMessageDeliveryStatus.sent;

    return ChatMessageModel(
      id: dto.id,
      roomId: roomId,
      senderId: dto.authorId ?? 'unknown',
      senderName: dto.authorName?.trim().isNotEmpty == true
          ? dto.authorName!.trim()
          : 'Member',
      senderAvatarUrl: dto.authorAvatarUrl,
      content: dto.body,
      createdAt: dto.createdAt ?? DateTime.now(),
      isMine: isMine,
      replyToId: dto.parentId,
      replyPreview: replyPreview,
      // Note: Group comments from the current API might not have native media attachments 
      // mapped through CommentApiDto unless added later.
      attachmentPath: null,
      attachmentKind: null,
      deliveryStatus: deliveryStatus,
      seenReceipts: receipts,
    );
  }
}
