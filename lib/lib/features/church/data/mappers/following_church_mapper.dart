import 'package:faithconnect/features/church/data/dto/church_api_dto.dart';
import 'package:faithconnect/features/church/domain/entities/following_church.dart';

abstract final class FollowingChurchMapper {
  FollowingChurchMapper._();

  static FollowingChurch toEntity(ChurchApiDto dto) {
    return FollowingChurch(
      id: dto.id,
      name: dto.name,
      slug: dto.slug,
      logoUrl: dto.displayAvatarUrl,
      coverImageUrl: dto.displayImageUrl,
      city: dto.city,
      isVerified: dto.isVerified,
      followerCount: dto.followerCount,
    );
  }

  static List<FollowingChurch> toEntityList(List<ChurchApiDto> dtos) =>
      dtos.map(toEntity).toList();
}
