import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/chat/data/dto/group_member_api_dto.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';

abstract final class GroupMemberMapper {
  GroupMemberMapper._();

  static GroupMember fromDto(GroupMemberApiDto dto) {
    final name = dto.name?.trim();
    return GroupMember(
      id: dto.id.isNotEmpty ? dto.id : dto.userId,
      userId: dto.userId.isNotEmpty ? dto.userId : dto.id,
      name: name != null && name.isNotEmpty ? name : 'Member',
      avatarUrl: MediaUrlResolver.normalize(dto.avatarUrl, imageOnly: true),
      role: dto.role?.trim().isNotEmpty == true ? dto.role!.trim() : null,
      isOnline: dto.isOnline,
      lastSeenAt: dto.lastSeenAt,
      lastSeenText: dto.lastSeenText,
      joinedAt: dto.joinedAt,
    );
  }
}
