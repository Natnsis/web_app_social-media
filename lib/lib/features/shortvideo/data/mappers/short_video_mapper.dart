import 'package:faithconnect/core/constants/nova_player_config.dart';
import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/shortvideo/data/dto/short_api_dto.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';

/// Maps [ShortApiDto] from `GET /v1/shorts` to the [ShortVideo] feed entity.
abstract final class ShortVideoMapper {
  ShortVideoMapper._();

  static ShortVideo fromDto(ShortApiDto dto) {
    final churchName = dto.church?.name.trim();
    final authorName = churchName != null && churchName.isNotEmpty
        ? churchName
        : 'Community';

    final authorId = dto.church?.id.trim().isNotEmpty == true
        ? dto.church!.id
        : (dto.churchId.isNotEmpty ? dto.churchId : null);

    final authorAvatarUrl = MediaUrlResolver.normalize(
      dto.church?.logoUrl,
      imageOnly: true,
    );

    final streamCode = _resolveStreamCode(dto);
    final novaAppId = _resolveNovaAppId(dto);
    final hasNovaStream =
        streamCode != null && novaAppId != null && novaAppId.isNotEmpty;

    // Nova shorts: play via streamCode + appId — not raw Nova CDN MP4 URLs.
    final resolvedVideoUrl = hasNovaStream
        ? null
        : MediaUrlResolver.normalize(
            _resolveDirectVideoUrl(dto),
            imageOnly: false,
          );

    final caption = _buildCaption(dto.title, dto.description);
    final thumbnailUrl = MediaUrlResolver.posterUrl(
          authorAvatarUrl ?? dto.novaFile?.novaUrl ?? dto.videoUrl,
        ) ??
        '';

    return ShortVideo(
      id: dto.id,
      authorName: authorName,
      authorProfileId: authorId,
      authorAvatarUrl: authorAvatarUrl,
      caption: caption,
      thumbnailUrl: thumbnailUrl,
      videoUrl: resolvedVideoUrl,
      streamCode: streamCode,
      novaAppId: novaAppId,
      audioLabel: _buildAudioLabel(authorName, dto.timeAgo),
      likeCount: dto.likeCount,
      reflectionCount: dto.commentCount,
      viewCount: dto.viewCount,
      isLiked: dto.isLikedByMe,
    );
  }

  /// Nova play session code (`novaFile.streamCode`), not the DB `novaVideoId`.
  static String? _resolveStreamCode(ShortApiDto dto) {
    final code = dto.novaFile?.streamCode?.trim();
    if (code != null && code.isNotEmpty) return code;
    return null;
  }

  static String? _resolveNovaAppId(ShortApiDto dto) {
    final fromNova = dto.novaFile?.appId?.trim();
    if (fromNova != null && fromNova.isNotEmpty) return fromNova;

    if (NovaPlayerConfig.isConfigured) {
      return NovaPlayerConfig.appId;
    }
    return null;
  }

  static String? _resolveDirectVideoUrl(ShortApiDto dto) {
    final candidates = [
      dto.videoUrl,
      dto.novaFile?.novaUrl,
    ];

    for (final raw in candidates) {
      final trimmed = raw?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      if (NovaPlayerConfig.isNovaHostedMediaUrl(trimmed)) continue;
      return trimmed;
    }

    return null;
  }

  static String _buildCaption(String title, String description) {
    final t = title.trim();
    final d = description.trim();
    if (t.isEmpty) return d;
    if (d.isEmpty) return t;
    return '$t\n\n$d';
  }

  static String _buildAudioLabel(String authorName, String? timeAgo) {
    final label = timeAgo?.trim();
    if (label != null && label.isNotEmpty) {
      return 'Original Audio - $authorName · $label';
    }
    return 'Original Audio - $authorName';
  }
}
