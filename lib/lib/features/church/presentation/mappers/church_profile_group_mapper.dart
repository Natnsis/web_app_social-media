import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_group.dart';

abstract final class ChurchProfileGroupMapper {
  ChurchProfileGroupMapper._();

  static ChatRoom toChatRoom(ChurchProfileGroup group) {
    final name = group.name.trim();
    return ChatRoom(
      id: group.id,
      title: name.isNotEmpty ? name : 'Group',
      type: ChatRoomType.group,
      avatarUrl: group.coverImageUrl,
      initials: name.isNotEmpty ? name[0].toUpperCase() : 'G',
      isPrivate: group.isPrivate,
      memberCount: group.memberCount,
    );
  }
}
