import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/services/socket/messaging_socket_payloads.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';

/// Outgoing payload for `group:message:send` → `{ groupId, body }`.
class GroupMessageSendPayload extends Equatable {
  final String groupId;
  final String? body;
  final String? mediaUrl;

  const GroupMessageSendPayload({
    required this.groupId,
    this.body,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() {
    final bodyText = body?.trim();
    final media = mediaUrl?.trim();
    return {
      'groupId': groupId.trim(),
      'body': bodyText ?? '',
      if (media != null && media.isNotEmpty) 'mediaUrl': media,
    };
  }

  bool get isValid {
    final bodyText = body?.trim() ?? '';
    final media = mediaUrl?.trim() ?? '';
    return groupId.trim().isNotEmpty && (bodyText.isNotEmpty || media.isNotEmpty);
  }

  @override
  List<Object?> get props => [groupId, body, mediaUrl];
}

/// Outgoing payload for `group:message:reply` → `{ groupId, parentId, body }`.
class GroupMessageReplyPayload extends Equatable {
  final String groupId;
  final String parentId;
  final String? body;
  final String? mediaUrl;

  const GroupMessageReplyPayload({
    required this.groupId,
    required this.parentId,
    this.body,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() {
    final bodyText = body?.trim();
    final media = mediaUrl?.trim();
    return {
      'groupId': groupId.trim(),
      'parentId': parentId.trim(),
      'body': bodyText ?? '',
      if (media != null && media.isNotEmpty) 'mediaUrl': media,
    };
  }

  bool get isValid {
    final bodyText = body?.trim() ?? '';
    final media = mediaUrl?.trim() ?? '';
    return groupId.trim().isNotEmpty &&
        parentId.trim().isNotEmpty &&
        (bodyText.isNotEmpty || media.isNotEmpty);
  }

  @override
  List<Object?> get props => [groupId, parentId, body, mediaUrl];
}

/// Outgoing payload for `group:message:update` → `{ groupId, messageId, body }`.
class GroupMessageUpdatePayload extends Equatable {
  final String groupId;
  final String messageId;
  final String body;

  const GroupMessageUpdatePayload({
    required this.groupId,
    required this.messageId,
    required this.body,
  });

  Map<String, dynamic> toJson() => {
        'groupId': groupId.trim(),
        'messageId': messageId.trim(),
        'body': body.trim(),
      };

  bool get isValid =>
      groupId.trim().isNotEmpty &&
      messageId.trim().isNotEmpty &&
      body.trim().isNotEmpty;

  @override
  List<Object?> get props => [groupId, messageId, body];
}

/// Outgoing payload for `group:message:delete` → `{ groupId, messageId }`.
class GroupMessageDeletePayload extends Equatable {
  final String groupId;
  final String messageId;

  const GroupMessageDeletePayload({
    required this.groupId,
    required this.messageId,
  });

  Map<String, dynamic> toJson() => {
        'groupId': groupId.trim(),
        'messageId': messageId.trim(),
      };

  bool get isValid =>
      groupId.trim().isNotEmpty && messageId.trim().isNotEmpty;

  @override
  List<Object?> get props => [groupId, messageId];
}

/// Outgoing payload for `group:typing:start` / `group:typing:stop` → `{ groupId }`.
class GroupTypingEmitPayload extends Equatable {
  final String groupId;

  const GroupTypingEmitPayload({required this.groupId});

  Map<String, dynamic> toJson() => {'groupId': groupId.trim()};

  bool get isValid => groupId.trim().isNotEmpty;

  @override
  List<Object?> get props => [groupId];
}

/// Incoming group message from `group:message:new` / `group:message:updated`.
class GroupSocketMessage extends Equatable {
  final String id;
  final String groupId;
  final String body;
  final String senderId;
  final String? senderName;
  final String? parentId;
  final DateTime createdAt;

  /// Remote media URL from the group socket payload (`mediaUrl` / `media_url`).
  /// Forwarded through [toMessagingFormat] and [toChatMessage] so the bubble
  /// renders the image exactly like a direct-message image.
  final String? mediaUrl;

  const GroupSocketMessage({
    required this.id,
    required this.groupId,
    required this.body,
    required this.senderId,
    this.senderName,
    this.parentId,
    required this.createdAt,
    this.mediaUrl,
  });

  factory GroupSocketMessage.fromDynamic(dynamic raw) {
    final map = _asMap(raw);
    final id = _string(map, 'id') ??
        _string(map, 'messageId') ??
        _string(map, 'commentId') ??
        '';
    final groupId = _string(map, 'groupId') ??
        _string(map, 'group_id') ??
        '';
    final body = _string(map, 'body') ??
        _string(map, 'content') ??
        _string(map, 'text') ??
        '';
    final senderMap = _asMap(map['sender'] ?? map['author']);
    final senderId = _string(map, 'senderId') ??
        _string(map, 'sender_id') ??
        _string(map, 'userId') ??
        _string(map, 'authorId') ??
        _string(senderMap, 'id') ??
        '';
    final senderName = _string(map, 'senderName') ??
        _string(map, 'sender_name') ??
        _string(map, 'authorName') ??
        _string(senderMap, 'fullName') ??
        _string(senderMap, 'full_name') ??
        _string(senderMap, 'name');
    final parentId = _string(map, 'parentId') ??
        _string(map, 'parent_id') ??
        _string(map, 'replyToId');
    final createdRaw =
        map['createdAt'] ?? map['created_at'] ?? map['timestamp'];

    // Accept both camelCase and snake_case mediaUrl keys.
    final mediaUrl = _string(map, 'mediaUrl') ?? _string(map, 'media_url');

    return GroupSocketMessage(
      id: id.isNotEmpty ? id : 'group-${DateTime.now().microsecondsSinceEpoch}',
      groupId: groupId,
      body: body,
      senderId: senderId,
      senderName: senderName,
      parentId: parentId,
      createdAt:
          DateTime.tryParse(createdRaw?.toString() ?? '') ?? DateTime.now(),
      mediaUrl: mediaUrl,
    );
  }

  /// Resolves the [MediaUploadKind] for a remote [url] by inspecting the extension.
  static MediaUploadKind? _kindFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final lower = url.toLowerCase().split('?').first;
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi')) {
      return MediaUploadKind.video;
    }
    return MediaUploadKind.image;
  }

  /// Convert to the unified [MessagingSocketMessage] format so the shared
  /// [ChatBloc] pipeline (incoming message → bubble) handles group messages
  /// identically to direct messages — including the [mediaUrl].
  MessagingSocketMessage toMessagingFormat() {
    return MessagingSocketMessage(
      id: id,
      conversationId: groupId,
      body: body,
      senderId: senderId,
      senderName: senderName,
      replyToId: parentId,
      createdAt: createdAt,
      mediaUrl: mediaUrl,
    );
  }

  ChatMessage toChatMessage({String? currentUserId}) {
    final mine = currentUserId != null &&
        currentUserId.isNotEmpty &&
        senderId == currentUserId;

    final attachmentKind = _kindFromUrl(mediaUrl);

    return ChatMessage(
      id: id,
      roomId: groupId,
      senderId: senderId.isNotEmpty ? senderId : 'unknown',
      senderName: senderName?.trim().isNotEmpty == true
          ? senderName!.trim()
          : (mine ? 'You' : 'Member'),
      content: body,
      createdAt: createdAt,
      isMine: mine,
      replyToId: parentId,
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
      [id, groupId, body, senderId, senderName, parentId, createdAt, mediaUrl];
}

/// Payload from `group:message:deleted`.
class GroupMessageDeletedPayload extends Equatable {
  final String messageId;
  final String? groupId;

  const GroupMessageDeletedPayload({
    required this.messageId,
    this.groupId,
  });

  factory GroupMessageDeletedPayload.fromDynamic(dynamic raw) {
    final map = GroupSocketMessage._asMap(raw);
    return GroupMessageDeletedPayload(
      messageId: GroupSocketMessage._string(map, 'messageId') ??
          GroupSocketMessage._string(map, 'message_id') ??
          GroupSocketMessage._string(map, 'commentId') ??
          GroupSocketMessage._string(map, 'id') ??
          '',
      groupId: GroupSocketMessage._string(map, 'groupId') ??
          GroupSocketMessage._string(map, 'group_id'),
    );
  }

  MessageDeletedPayload toMessagingFormat() {
    return MessageDeletedPayload(
      messageId: messageId,
      conversationId: groupId,
    );
  }

  @override
  List<Object?> get props => [messageId, groupId];
}

/// Payload from `group:typing:start` / `group:typing:stop`.
class GroupTypingPayload extends Equatable {
  final String groupId;
  final String userId;

  const GroupTypingPayload({
    required this.groupId,
    required this.userId,
  });

  factory GroupTypingPayload.fromDynamic(dynamic raw) {
    final map = GroupSocketMessage._asMap(raw);
    return GroupTypingPayload(
      groupId: GroupSocketMessage._string(map, 'groupId') ??
          GroupSocketMessage._string(map, 'group_id') ??
          '',
      userId: GroupSocketMessage._string(map, 'userId') ??
          GroupSocketMessage._string(map, 'user_id') ??
          '',
    );
  }

  TypingPayload toMessagingFormat() {
    return TypingPayload(
      conversationId: groupId,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [groupId, userId];
}

/// Live membership event from `group:member:joined` / `group:member:left`.
class GroupMemberEventPayload extends Equatable {
  final String groupId;
  final String userId;
  final String? userName;
  final bool joined;

  const GroupMemberEventPayload({
    required this.groupId,
    required this.userId,
    this.userName,
    required this.joined,
  });

  factory GroupMemberEventPayload.fromDynamic(
    dynamic raw, {
    required bool joined,
  }) {
    final map = GroupSocketMessage._asMap(raw);
    return GroupMemberEventPayload(
      groupId: GroupSocketMessage._string(map, 'groupId') ??
          GroupSocketMessage._string(map, 'group_id') ??
          '',
      userId: GroupSocketMessage._string(map, 'userId') ??
          GroupSocketMessage._string(map, 'user_id') ??
          '',
      userName: GroupSocketMessage._string(map, 'userName') ??
          GroupSocketMessage._string(map, 'fullName'),
      joined: joined,
    );
  }

  @override
  List<Object?> get props => [groupId, userId, userName, joined];
}

/// Incoming group message seen payload from `group:message:seen`.
class GroupMessageSeenPayload extends Equatable {
  final String groupId;
  final String messageId;
  final String userId;
  final DateTime seenAt;
  final Map<String, dynamic> seenBy;

  const GroupMessageSeenPayload({
    required this.groupId,
    required this.messageId,
    required this.userId,
    required this.seenAt,
    required this.seenBy,
  });

  factory GroupMessageSeenPayload.fromDynamic(dynamic raw) {
    final map = GroupSocketMessage._asMap(raw);
    return GroupMessageSeenPayload(
      groupId: GroupSocketMessage._string(map, 'groupId') ?? '',
      messageId: GroupSocketMessage._string(map, 'messageId') ?? '',
      userId: GroupSocketMessage._string(map, 'userId') ?? '',
      seenAt: DateTime.tryParse(map['seenAt']?.toString() ?? '') ?? DateTime.now(),
      seenBy: GroupSocketMessage._asMap(map['seenBy']),
    );
  }

  @override
  List<Object?> get props => [groupId, messageId, userId, seenAt, seenBy];
}
