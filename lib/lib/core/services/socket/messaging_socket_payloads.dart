import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_delivery_status.dart';

/// Outgoing payload for `message:send` → `{ conversationId, body }` or `{ recipientId, body }`.
class DirectMessageSendPayload extends Equatable {
  final String? conversationId;
  final String? recipientId;
  final String? body;
  final String? mediaUrl;

  const DirectMessageSendPayload({
    this.conversationId,
    this.recipientId,
    this.body,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() {
    final convId = conversationId?.trim();
    final recipId = recipientId?.trim();
    final bodyText = body?.trim();
    final media = mediaUrl?.trim();
    return {
      if (convId != null && convId.isNotEmpty) 'conversationId': convId,
      if (recipId != null && recipId.isNotEmpty) 'recipientId': recipId,
      'body': bodyText ?? '',
      if (media != null && media.isNotEmpty) 'mediaUrl': media,
    };
  }

  bool get isValid {
    final bodyText = body?.trim() ?? '';
    final media = mediaUrl?.trim() ?? '';
    if (bodyText.isEmpty && media.isEmpty) return false;
    final convId = conversationId?.trim();
    final recipId = recipientId?.trim();
    final hasConv = convId != null && convId.isNotEmpty;
    final hasRecip = recipId != null && recipId.isNotEmpty;
    return hasConv != hasRecip;
  }

  @override
  List<Object?> get props => [conversationId, recipientId, body, mediaUrl];
}

/// Outgoing payload for `message:reply` → `{ conversationId, replyToId, body }`.
class DirectMessageReplyPayload extends Equatable {
  final String conversationId;
  final String replyToId;
  final String? body;
  final String? mediaUrl;

  const DirectMessageReplyPayload({
    required this.conversationId,
    required this.replyToId,
    this.body,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() {
    final bodyText = body?.trim();
    final media = mediaUrl?.trim();
    return {
      'conversationId': conversationId.trim(),
      'replyToId': replyToId.trim(),
      'body': bodyText ?? '',
      if (media != null && media.isNotEmpty) 'mediaUrl': media,
    };
  }

  bool get isValid {
    final bodyText = body?.trim() ?? '';
    final media = mediaUrl?.trim() ?? '';
    return conversationId.trim().isNotEmpty &&
        replyToId.trim().isNotEmpty &&
        (bodyText.isNotEmpty || media.isNotEmpty);
  }

  @override
  List<Object?> get props => [conversationId, replyToId, body, mediaUrl];
}

/// Outgoing payload for `message:update` → `{ messageId, body }`.
class DirectMessageUpdatePayload extends Equatable {
  final String messageId;
  final String body;

  const DirectMessageUpdatePayload({
    required this.messageId,
    required this.body,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId.trim(),
        'body': body.trim(),
      };

  bool get isValid => messageId.trim().isNotEmpty && body.trim().isNotEmpty;

  @override
  List<Object?> get props => [messageId, body];
}

/// Outgoing payload for `message:delete` → `{ messageId }`.
class DirectMessageDeletePayload extends Equatable {
  final String messageId;

  const DirectMessageDeletePayload({required this.messageId});

  Map<String, dynamic> toJson() => {'messageId': messageId.trim()};

  bool get isValid => messageId.trim().isNotEmpty;

  @override
  List<Object?> get props => [messageId];
}

/// Outgoing payload for `message:read` → `{ conversationId }`.
class DirectConversationReadPayload extends Equatable {
  final String conversationId;

  const DirectConversationReadPayload({required this.conversationId});

  Map<String, dynamic> toJson() => {'conversationId': conversationId.trim()};

  bool get isValid => conversationId.trim().isNotEmpty;

  @override
  List<Object?> get props => [conversationId];
}

/// Outgoing payload for `typing:start` / `typing:stop` → `{ conversationId }`.
class DirectTypingEmitPayload extends Equatable {
  final String conversationId;

  const DirectTypingEmitPayload({required this.conversationId});

  Map<String, dynamic> toJson() => {'conversationId': conversationId.trim()};

  bool get isValid => conversationId.trim().isNotEmpty;

  @override
  List<Object?> get props => [conversationId];
}

/// Incoming payload from `message:new` / `message:updated`.
class MessagingSocketMessage extends Equatable {
  final String id;
  final String conversationId;
  final String body;
  final String senderId;
  final String? senderName;
  final String? replyToId;
  final DateTime createdAt;

  /// Remote media URL delivered via `message:send` / `message:new` as `mediaUrl`.
  /// Stored as [attachmentPath] on the resulting [ChatMessage] so existing
  /// rendering logic (attachment bubble) can display the image.
  final String? mediaUrl;

  const MessagingSocketMessage({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.senderId,
    this.senderName,
    this.replyToId,
    required this.createdAt,
    this.mediaUrl,
  });

  factory MessagingSocketMessage.fromDynamic(dynamic raw) {
    final map = _asMap(raw);
    final id = _string(map, 'id') ?? '';
    final conversationId = _string(map, 'conversationId') ??
        _string(map, 'conversation_id') ??
        _string(map, 'roomId') ??
        '';
    final body = _string(map, 'body') ??
        _string(map, 'content') ??
        _string(map, 'text') ??
        '';
    final senderMap = _asMap(map['sender'] ?? map['author']);
    final senderId = _string(map, 'senderId') ??
        _string(map, 'sender_id') ??
        _string(map, 'userId') ??
        _string(senderMap, 'id') ??
        '';
    final senderName = _string(map, 'senderName') ??
        _string(map, 'sender_name') ??
        _string(map, 'authorName') ??
        _string(senderMap, 'fullName') ??
        _string(senderMap, 'full_name') ??
        _string(senderMap, 'name');
    final replyToMap = _asMap(map['replyTo'] ?? map['reply_to']);
    final replyToId = _string(map, 'replyToId') ??
        _string(map, 'reply_to_id') ??
        _string(replyToMap, 'id');
    final createdRaw = map['createdAt'] ?? map['created_at'] ?? map['timestamp'];

    // Accept both camelCase and snake_case mediaUrl keys.
    final mediaUrl = _string(map, 'mediaUrl') ?? _string(map, 'media_url');

    return MessagingSocketMessage(
      id: id.isNotEmpty ? id : 'socket-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      body: body,
      senderId: senderId,
      senderName: senderName,
      replyToId: replyToId,
      createdAt: DateTime.tryParse(createdRaw?.toString() ?? '') ?? DateTime.now(),
      mediaUrl: mediaUrl,
    );
  }

  /// Resolves the kind for a remote [mediaUrl] by inspecting the path extension.
  static MediaUploadKind? _kindFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final lower = url.toLowerCase().split('?').first; // strip query params
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi')) {
      return MediaUploadKind.video;
    }
    // Default to image for all other media URLs.
    return MediaUploadKind.image;
  }

  ChatMessage toChatMessage({String? currentUserId}) {
    final mine = currentUserId != null &&
        currentUserId.isNotEmpty &&
        senderId == currentUserId;

    final attachmentKind = _kindFromUrl(mediaUrl);

    return ChatMessage(
      id: id,
      roomId: conversationId,
      senderId: senderId.isNotEmpty ? senderId : 'unknown',
      senderName: senderName?.trim().isNotEmpty == true
          ? senderName!.trim()
          : (mine ? 'You' : 'Member'),
      content: body,
      createdAt: createdAt,
      isMine: mine,
      replyToId: replyToId,
      deliveryStatus: mine
          ? ChatMessageDeliveryStatus.sent
          : ChatMessageDeliveryStatus.sent,
      // Map remote mediaUrl → attachmentPath so the bubble renders it.
      attachmentPath: mediaUrl,
      attachmentKind: attachmentKind,
    );
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  static String? _string(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  @override
  List<Object?> get props =>
      [id, conversationId, body, senderId, senderName, replyToId, createdAt, mediaUrl];
}

/// Payload from `message:deleted`.
class MessageDeletedPayload extends Equatable {
  final String messageId;
  final String? conversationId;

  const MessageDeletedPayload({
    required this.messageId,
    this.conversationId,
  });

  factory MessageDeletedPayload.fromDynamic(dynamic raw) {
    final map = MessagingSocketMessage._asMap(raw);
    return MessageDeletedPayload(
      messageId: MessagingSocketMessage._string(map, 'messageId') ??
          MessagingSocketMessage._string(map, 'message_id') ??
          MessagingSocketMessage._string(map, 'id') ??
          '',
      conversationId: MessagingSocketMessage._string(map, 'conversationId') ??
          MessagingSocketMessage._string(map, 'conversation_id'),
    );
  }

  @override
  List<Object?> get props => [messageId, conversationId];
}

/// Payload from `conv:read` / server `message:read`.
class ConversationReadPayload extends Equatable {
  final String conversationId;
  final String readBy;

  const ConversationReadPayload({
    required this.conversationId,
    required this.readBy,
  });

  factory ConversationReadPayload.fromDynamic(dynamic raw) {
    final map = MessagingSocketMessage._asMap(raw);
    return ConversationReadPayload(
      conversationId: MessagingSocketMessage._string(map, 'conversationId') ??
          MessagingSocketMessage._string(map, 'conversation_id') ??
          '',
      readBy: MessagingSocketMessage._string(map, 'readBy') ??
          MessagingSocketMessage._string(map, 'read_by') ??
          MessagingSocketMessage._string(map, 'userId') ??
          '',
    );
  }

  @override
  List<Object?> get props => [conversationId, readBy];
}

/// Payload from `typing:start` / `typing:stop`.
class TypingPayload extends Equatable {
  final String conversationId;
  final String userId;

  const TypingPayload({
    required this.conversationId,
    required this.userId,
  });

  factory TypingPayload.fromDynamic(dynamic raw) {
    final map = MessagingSocketMessage._asMap(raw);
    return TypingPayload(
      conversationId: MessagingSocketMessage._string(map, 'conversationId') ??
          MessagingSocketMessage._string(map, 'conversation_id') ??
          '',
      userId: MessagingSocketMessage._string(map, 'userId') ??
          MessagingSocketMessage._string(map, 'user_id') ??
          '',
    );
  }

  @override
  List<Object?> get props => [conversationId, userId];
}

/// Payload from `presence:online` / `presence:offline`.
class PresencePayload extends Equatable {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeenAt;

  const PresencePayload({
    required this.userId,
    required this.isOnline,
    this.lastSeenAt,
  });

  factory PresencePayload.fromDynamic(dynamic raw, {required bool isOnline}) {
    final map = MessagingSocketMessage._asMap(raw);
    final lastSeenRaw = map['lastSeenAt'] ?? map['last_seen_at'];
    return PresencePayload(
      userId: MessagingSocketMessage._string(map, 'userId') ??
          MessagingSocketMessage._string(map, 'user_id') ??
          '',
      isOnline: isOnline,
      lastSeenAt: lastSeenRaw != null
          ? DateTime.tryParse(lastSeenRaw.toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [userId, isOnline, lastSeenAt];
}
