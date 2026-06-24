import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/chat/data/dto/messaging_message_api_dto.dart';
import 'package:faithconnect/features/chat/data/models/chat_message_model.dart';
import 'package:faithconnect/features/chat/data/models/chat_room_model.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_reply_preview.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/domain/entities/direct_conversation_participants.dart';
import 'package:intl/intl.dart';

abstract final class MessagingInboxMapper {
  MessagingInboxMapper._();

  /// Groups [messages] by conversation and builds direct inbox rows.
  static List<ChatRoomModel> roomsFromMessages(
    List<MessagingMessageApiDto> messages, {
    String? currentUserId,
  }) {
    final grouped = <String, List<MessagingMessageApiDto>>{};
    for (final message in messages) {
      if (message.deletedAt != null) continue;
      final conversationId = message.conversationId.trim();
      if (conversationId.isEmpty) continue;
      grouped.putIfAbsent(conversationId, () => []).add(message);
    }

    final rooms = <ChatRoomModel>[];
    for (final entry in grouped.entries) {
      final room = _roomFromConversationMessages(
        entry.value,
        currentUserId: currentUserId,
      );
      if (room != null) rooms.add(room);
    }

    rooms.sort(
      (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
    return rooms;
  }

  static Map<String, List<ChatMessageModel>> messagesByConversation(
    List<MessagingMessageApiDto> messages, {
    String? currentUserId,
  }) {
    final grouped = <String, List<ChatMessageModel>>{};
    for (final dto in messages) {
      if (dto.deletedAt != null) continue;
      final conversationId = dto.conversationId.trim();
      if (conversationId.isEmpty) continue;
      grouped
          .putIfAbsent(conversationId, () => [])
          .add(toMessageModel(dto, currentUserId: currentUserId));
    }

    for (final list in grouped.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return grouped;
  }

  static DirectConversationParticipants? participantsFromConversation(
    MessagingConversationApiDto? conversation,
  ) {
    if (conversation == null || conversation.id.isEmpty) return null;
    final a = conversation.participantA;
    final b = conversation.participantB;
    if (a.id.isEmpty && b.id.isEmpty) return null;

    return DirectConversationParticipants.fromApi(
      participantAId: a.id,
      participantAName: a.fullName,
      participantAAvatarUrl:
          MediaUrlResolver.normalize(a.avatarUrl, imageOnly: true),
      participantBId: b.id,
      participantBName: b.fullName,
      participantBAvatarUrl:
          MediaUrlResolver.normalize(b.avatarUrl, imageOnly: true),
    );
  }

  static ChatMessageModel toMessageModel(
    MessagingMessageApiDto dto, {
    String? currentUserId,
    DirectConversationParticipants? participants,
  }) {
    final resolvedParticipants =
        participants ?? participantsFromConversation(dto.conversation);
    final isMine = resolvedParticipants?.isMessageMine(
          dto.senderId,
          currentUserId,
        ) ??
        _isMineFallback(dto.senderId, currentUserId);

    final senderName = _senderName(
      dto: dto,
      participants: resolvedParticipants,
      isMine: isMine,
    );
    final senderAvatar = _senderAvatar(
      dto: dto,
      participants: resolvedParticipants,
    );

    final replyPreview = _replyPreviewFromDto(dto, currentUserId: currentUserId);

    return ChatMessageModel(
      id: dto.id,
      roomId: dto.conversationId,
      senderId: dto.senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatar,
      content: dto.body,
      createdAt: dto.createdAt,
      isMine: isMine,
      replyToId: dto.replyToId,
      replyPreview: replyPreview,
      attachmentPath: dto.mediaUrl,
      attachmentKind: dto.mediaUrl != null ? MediaUploadKind.image : null,
    );
  }

  static ChatRoomModel? roomFromConversation(
    MessagingConversationApiDto conversation,
    List<MessagingMessageApiDto> messages, {
    String? currentUserId,
  }) {
    if (messages.isEmpty) return null;
    return _roomFromConversationMessages(
      messages,
      currentUserId: currentUserId,
      conversationOverride: conversation,
    );
  }

  static ChatRoomModel? _roomFromConversationMessages(
    List<MessagingMessageApiDto> messages, {
    String? currentUserId,
    MessagingConversationApiDto? conversationOverride,
  }) {
    if (messages.isEmpty) return null;

    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest = messages.first;
    final conversation = conversationOverride ?? latest.conversation;
    if (conversation == null || conversation.id.isEmpty) return null;

    final participants = participantsFromConversation(conversation);
    if (participants == null) return null;

    final peer = participants.peerForUser(currentUserId);
    final peerName = peer.name;
    final me = currentUserId?.trim();
    final unreadCount = messages
        .where(
          (message) =>
              !message.isRead &&
              (me == null || me.isEmpty || message.senderId != me),
        )
        .length;
    final isMine = participants.isMessageMine(latest.senderId, currentUserId);
    final lastSenderName = isMine
        ? 'You'
        : (latest.sender.fullName.trim().isNotEmpty
            ? latest.sender.fullName.trim()
            : participants.participantName(latest.senderId));

    return ChatRoomModel(
      id: conversation.id,
      title: peerName,
      type: ChatRoomType.direct,
      peerUserId: peer.id.isNotEmpty ? peer.id : null,
      avatarUrl: MediaUrlResolver.normalize(peer.avatarUrl, imageOnly: true),
      lastMessage: latest.body.trim().isNotEmpty ? latest.body.trim() : null,
      lastSenderName: lastSenderName,
      timestampLabel: _formatListTimestamp(latest.createdAt),
      updatedAt: latest.createdAt,
      unreadCount: unreadCount,
      hasUnreadDot: unreadCount > 0,
      initials: peerName.isNotEmpty ? peerName[0].toUpperCase() : 'M',
      directParticipants: participants,
    );
  }

  static ChatMessageReplyPreview? _replyPreviewFromDto(
    MessagingMessageApiDto dto, {
    String? currentUserId,
  }) {
    final replyId = dto.replyToId?.trim();
    final body = dto.replyToBody?.trim();
    if (replyId == null || replyId.isEmpty || body == null || body.isEmpty) {
      return null;
    }

    final me = currentUserId?.trim();
    final replySenderId = dto.replyToSenderId?.trim();
    final originalMine = me != null &&
        me.isNotEmpty &&
        replySenderId != null &&
        replySenderId == me;

    var senderLabel = dto.replyToSenderName?.trim();
    if (originalMine) {
      senderLabel = 'You';
    } else if (senderLabel == null || senderLabel.isEmpty) {
      senderLabel = 'Member';
    }

    return ChatMessageReplyPreview(
      messageId: replyId,
      senderName: senderLabel,
      content: body,
      isOriginalMine: originalMine,
    );
  }

  static bool _isMineFallback(String senderId, String? currentUserId) {
    final me = currentUserId?.trim();
    return me != null && me.isNotEmpty && senderId == me;
  }

  static String _senderName({
    required MessagingMessageApiDto dto,
    required DirectConversationParticipants? participants,
    required bool isMine,
  }) {
    if (isMine) return 'You';
    final fromDto = dto.sender.fullName.trim();
    if (fromDto.isNotEmpty) return fromDto;
    return participants?.participantName(dto.senderId) ?? 'Member';
  }

  static String? _senderAvatar({
    required MessagingMessageApiDto dto,
    required DirectConversationParticipants? participants,
  }) {
    final fromDto =
        MediaUrlResolver.normalize(dto.sender.avatarUrl, imageOnly: true);
    if (fromDto != null && fromDto.isNotEmpty) return fromDto;
    return participants?.participantAvatar(dto.senderId);
  }

  static String _formatListTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (day == today) {
      return DateFormat('h:mm a').format(dateTime);
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    }
    return DateFormat('MMM d').format(dateTime);
  }
}
