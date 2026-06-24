import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/church/data/dto/church_member_api_dto.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';

abstract final class ChurchMemberMapper {
  ChurchMemberMapper._();

  static ChurchMember toEntity(ChurchMemberApiDto dto) {
    final name = dto.name?.trim();
    return ChurchMember(
      id: dto.id.isNotEmpty ? dto.id : dto.userId,
      userId: dto.userId,
      name: name != null && name.isNotEmpty ? name : 'Moderator',
      avatarUrl: MediaUrlResolver.normalize(dto.avatarUrl, imageOnly: true),
      role: dto.role?.trim().isNotEmpty == true ? dto.role!.trim() : 'Moderator',
    );
  }

  static List<ChurchMember> toEntityList(List<ChurchMemberApiDto> dtos) =>
      dtos.map(toEntity).toList();
}
