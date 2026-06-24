import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/shortvideo/data/dto/short_api_dto.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';

abstract final class ProfileShortClipMapper {
  ProfileShortClipMapper._();

  static ProfileShortClip fromDto(ShortApiDto dto) {
    final title = dto.title.trim().isNotEmpty
        ? dto.title.trim()
        : dto.description.trim();

    final thumbnail = MediaUrlResolver.normalize(
      dto.church?.logoUrl,
      imageOnly: true,
    );

    return ProfileShortClip(
      id: dto.id,
      title: title.isNotEmpty ? title : 'Short',
      thumbnailUrl: thumbnail ?? '',
      viewCount: dto.viewCount,
    );
  }

  static ProfileShortClip fromShortVideo(ShortVideo video) {
    final caption = video.caption.trim();
    final title = caption.contains('\n')
        ? caption.split('\n').first.trim()
        : caption;

    return ProfileShortClip(
      id: video.id,
      title: title.isNotEmpty ? title : 'Short',
      thumbnailUrl: video.thumbnailUrl.isNotEmpty
          ? video.thumbnailUrl
          : (video.authorAvatarUrl ?? ''),
      viewCount: video.viewCount,
    );
  }
}
