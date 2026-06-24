import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_delivery_status.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_reply_preview.dart';

abstract final class ChatMessageEnricher {
  ChatMessageEnricher._();

  /// Attaches reply quote previews from [replyToId] and applies read receipts.
  static List<ChatMessage> enrich(
    List<ChatMessage> messages, {
    String? peerUserId,
    String? lastReadByUserId,
  }) {
    final byId = {for (final message in messages) message.id: message};

    return messages
        .map(
          (message) => _withReplyPreview(
            _withReadReceipt(
              message,
              peerUserId: peerUserId,
              lastReadByUserId: lastReadByUserId,
            ),
            byId,
          ),
        )
        .toList(growable: false);
  }

  static ChatMessage _withReplyPreview(
    ChatMessage message,
    Map<String, ChatMessage> byId,
  ) {
    if (message.replyPreview != null) return message;

    final replyId = message.replyToId?.trim();
    if (replyId == null || replyId.isEmpty) return message;

    final original = byId[replyId];
    if (original == null) return message;

    return message.copyWith(
      replyPreview: ChatMessageReplyPreview(
        messageId: original.id,
        senderName: original.isMine ? 'You' : original.senderName,
        content: original.content,
        isOriginalMine: original.isMine,
      ),
    );
  }

  static ChatMessage _withReadReceipt(
    ChatMessage message, {
    String? peerUserId,
    String? lastReadByUserId,
  }) {
    if (!message.isMine) return message;
    if (message.id.startsWith('pending-')) {
      return message.copyWith(deliveryStatus: ChatMessageDeliveryStatus.sending);
    }

    final peer = peerUserId?.trim();
    final readBy = lastReadByUserId?.trim();
    if (peer != null &&
        peer.isNotEmpty &&
        readBy != null &&
        readBy.isNotEmpty &&
        readBy == peer) {
      return message.copyWith(deliveryStatus: ChatMessageDeliveryStatus.read);
    }

    if (message.seenReceipts.isNotEmpty) {
      return message.copyWith(deliveryStatus: ChatMessageDeliveryStatus.read);
    }

    if (message.deliveryStatus == ChatMessageDeliveryStatus.read) {
      return message;
    }

    return message.copyWith(deliveryStatus: ChatMessageDeliveryStatus.sent);
  }
}
