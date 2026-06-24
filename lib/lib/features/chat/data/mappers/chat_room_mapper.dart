import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/chat/data/dto/group_api_dto.dart';
import 'package:faithconnect/features/chat/data/models/chat_room_model.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:intl/intl.dart';

abstract final class ChatRoomMapper {
  ChatRoomMapper._();

  static ChatRoomModel fromGroupDto(GroupApiDto dto) {
    final title = dto.name.trim();
    return ChatRoomModel(
      id: dto.id,
      title: title.isNotEmpty ? title : 'Group',
      type: ChatRoomType.group,
      avatarUrl: MediaUrlResolver.normalize(dto.imageUrl, imageOnly: true),
      lastMessage: dto.lastMessage?.trim().isNotEmpty == true
          ? dto.lastMessage!.trim()
          : dto.description?.trim(),
      lastSenderName: dto.lastSenderName,
      timestampLabel: _formatListTimestamp(dto.updatedAt),
      updatedAt: dto.updatedAt,
      unreadCount: dto.unreadCount,
      isMuted: dto.isMuted,
      hasUnreadDot: dto.unreadCount > 0,
      initials: title.isNotEmpty ? title[0].toUpperCase() : 'G',
      isPrivate: dto.isPrivate,
      memberCount: dto.memberCount,
      statusSubtitle: dto.isPrivate ? 'Private group' : null,
    );
  }

  static String _formatListTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';

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
