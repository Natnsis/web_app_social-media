/// Participant embedded in messaging message / conversation payloads.
class MessagingParticipantApiDto {
  final String id;
  final String fullName;
  final String? avatarUrl;

  const MessagingParticipantApiDto({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });

  factory MessagingParticipantApiDto.fromJson(Map<String, dynamic> json) {
    final name = json['fullName'] as String? ??
        json['full_name'] as String? ??
        json['name'] as String? ??
        '';
    return MessagingParticipantApiDto(
      id: json['id']?.toString() ?? '',
      fullName: name.trim(),
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
    );
  }
}

/// Conversation block on `GET /v1/messaging/messages` items.
class MessagingConversationApiDto {
  final String id;
  final MessagingParticipantApiDto participantA;
  final MessagingParticipantApiDto participantB;

  const MessagingConversationApiDto({
    required this.id,
    required this.participantA,
    required this.participantB,
  });

  factory MessagingConversationApiDto.fromJson(Map<String, dynamic> json) {
    final participantAJson = _asMap(json['participantA'] ?? json['participant_a']);
    final participantBJson = _asMap(json['participantB'] ?? json['participant_b']);

    return MessagingConversationApiDto(
      id: json['id']?.toString() ?? '',
      participantA: participantAJson != null
          ? MessagingParticipantApiDto.fromJson(participantAJson)
          : const MessagingParticipantApiDto(id: '', fullName: ''),
      participantB: participantBJson != null
          ? MessagingParticipantApiDto.fromJson(participantBJson)
          : const MessagingParticipantApiDto(id: '', fullName: ''),
    );
  }

  /// Other participant for inbox title — prefers [participantB] when ambiguous.
  MessagingParticipantApiDto peerForInbox({String? currentUserId}) {
    final me = currentUserId?.trim();
    if (me != null && me.isNotEmpty) {
      if (participantA.id == me && participantB.id.isNotEmpty) {
        return participantB;
      }
      if (participantB.id == me && participantA.id.isNotEmpty) {
        return participantA;
      }
    }
    return participantB.id.isNotEmpty ? participantB : participantA;
  }
}

/// Message item from `GET /v1/messaging/messages`.
class MessagingMessageApiDto {
  final String id;
  final String conversationId;
  final String senderId;
  final String? replyToId;
  final String? replyToBody;
  final String? replyToSenderName;
  final String? replyToSenderId;
  final String body;
  final String? mediaUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final MessagingParticipantApiDto sender;
  final MessagingConversationApiDto? conversation;

  const MessagingMessageApiDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.replyToId,
    this.replyToBody,
    this.replyToSenderName,
    this.replyToSenderId,
    required this.body,
    this.mediaUrl,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.deletedAt,
    required this.sender,
    this.conversation,
  });

  factory MessagingMessageApiDto.fromJson(Map<String, dynamic> json) {
    final senderJson = _asMap(json['sender']);
    final conversationJson = _asMap(json['conversation']);
    final replyToJson = _asMap(json['replyTo'] ?? json['reply_to']);
    final replyToSenderJson = replyToJson != null
        ? _asMap(replyToJson['sender'] ?? replyToJson['author'])
        : null;

    return MessagingMessageApiDto(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ??
          json['conversation_id']?.toString() ??
          '',
      senderId: json['senderId']?.toString() ??
          json['sender_id']?.toString() ??
          senderJson?['id']?.toString() ??
          '',
      replyToId: json['replyToId']?.toString() ??
          json['reply_to_id']?.toString() ??
          replyToJson?['id']?.toString(),
      replyToBody: replyToJson?['body'] as String? ??
          replyToJson?['content'] as String? ??
          replyToJson?['text'] as String?,
      replyToSenderName: replyToSenderJson?['fullName'] as String? ??
          replyToSenderJson?['full_name'] as String? ??
          replyToSenderJson?['name'] as String? ??
          replyToJson?['senderName'] as String?,
      replyToSenderId: replyToSenderJson?['id']?.toString() ??
          replyToJson?['senderId']?.toString(),
      body: json['body'] as String? ?? json['content'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? json['media_url'] as String?,
      isRead: json['isRead'] == true || json['is_read'] == true,
      readAt: DateTime.tryParse(
        (json['readAt'] ?? json['read_at'])?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
          ) ??
          DateTime.now(),
      deletedAt: DateTime.tryParse(
        (json['deletedAt'] ?? json['deleted_at'])?.toString() ?? '',
      ),
      sender: senderJson != null
          ? MessagingParticipantApiDto.fromJson(senderJson)
          : const MessagingParticipantApiDto(id: '', fullName: 'Member'),
      conversation: conversationJson != null
          ? MessagingConversationApiDto.fromJson(conversationJson)
          : null,
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}
