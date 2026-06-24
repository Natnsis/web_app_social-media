import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.title,
    required super.type,
    super.avatarUrl,
    super.lastMessage,
    super.lastSenderName,
    super.timestampLabel,
    super.updatedAt,
    super.unreadCount,
    super.isMuted,
    super.isOnline,
    super.hasUnreadDot,
    super.initials,
    super.statusSubtitle,
    super.peerUserId,
    super.directParticipants,
    super.isPrivate,
    super.memberCount,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      type: _parseType(json['type']),
      avatarUrl: json['avatar_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastSenderName: json['last_sender_name'] as String?,
      timestampLabel: json['timestamp_label'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      unreadCount: json['unread_count'] as int? ?? 0,
      isMuted: json['is_muted'] as bool? ?? false,
      isOnline: json['is_online'] as bool? ?? false,
      hasUnreadDot: json['has_unread_dot'] as bool? ?? false,
      initials: json['initials'] as String?,
      statusSubtitle: json['status_subtitle'] as String?,
    );
  }

  static ChatRoomType _parseType(dynamic value) {
    if (value == 'group') return ChatRoomType.group;
    return ChatRoomType.direct;
  }

  ChatRoom toEntity() => ChatRoom(
        id: id,
        title: title,
        type: type,
        avatarUrl: avatarUrl,
        lastMessage: lastMessage,
        lastSenderName: lastSenderName,
        timestampLabel: timestampLabel,
        updatedAt: updatedAt,
        unreadCount: unreadCount,
        isMuted: isMuted,
        isOnline: isOnline,
        hasUnreadDot: hasUnreadDot,
        initials: initials,
        statusSubtitle: statusSubtitle,
        peerUserId: peerUserId,
        directParticipants: directParticipants,
        isPrivate: isPrivate,
        memberCount: memberCount,
      );
}
