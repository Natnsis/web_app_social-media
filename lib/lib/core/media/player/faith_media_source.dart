import 'package:faithconnect/core/constants/nova_player_config.dart';
import 'package:faithconnect/core/utils/media_url_resolver.dart';

/// Describes what to play — Nova stream code or a direct media URL.
sealed class FaithMediaSource {
  const FaithMediaSource();

  String? get posterUrl;
  bool get isLive;
}

/// Nova play-session stream (`appId` + `streamCode` from backend).
final class NovaStreamSource extends FaithMediaSource {
  final String streamCode;
  final String appId;
  @override
  final String? posterUrl;
  @override
  final bool isLive;
  final Map<String, dynamic>? userContext;

  const NovaStreamSource({
    required this.streamCode,
    required this.appId,
    this.posterUrl,
    this.isLive = false,
    this.userContext,
  });
}

/// Direct progressive or HLS URL via `video_player` (non-Nova CDN only).
final class DirectUrlSource extends FaithMediaSource {
  final String url;
  @override
  final String? posterUrl;
  @override
  final bool isLive;

  const DirectUrlSource({
    required this.url,
    this.posterUrl,
    this.isLive = false,
  });
}

/// Resolves the best playable source from API fields.
abstract final class FaithMediaSources {
  FaithMediaSources._();

  static FaithMediaSource resolve({
    String? streamCode,
    String? directUrl,
    String? posterUrl,
    String? appId,
    bool isLive = false,
    Map<String, dynamic>? userContext,
  }) {
    final resolvedAppId = (appId?.trim().isNotEmpty == true)
        ? appId!.trim()
        : NovaPlayerConfig.appId;

    final imagePoster = MediaUrlResolver.posterUrl(posterUrl);
    final code = streamCode?.trim();

    // Nova shorts: play via streamCode — never hit raw Nova CDN MP4 URLs (often 404).
    if (code != null && code.isNotEmpty && resolvedAppId.isNotEmpty) {
      return NovaStreamSource(
        streamCode: code,
        appId: resolvedAppId,
        posterUrl: imagePoster,
        isLive: isLive,
        userContext: userContext,
      );
    }

    final url = directUrl?.trim();
    if (url != null &&
        url.isNotEmpty &&
        !NovaPlayerConfig.isNovaHostedMediaUrl(url)) {
      return DirectUrlSource(
        url: url,
        posterUrl: imagePoster,
        isLive: isLive,
      );
    }

    throw ArgumentError(
      'FaithMediaSource requires a Nova streamCode (with NOVA_APP_ID) '
      'or a non-Nova directUrl.',
    );
  }

  /// Returns `null` when neither Nova nor a direct URL can be resolved.
  static FaithMediaSource? tryResolve({
    String? streamCode,
    String? directUrl,
    String? posterUrl,
    String? appId,
    bool isLive = false,
    Map<String, dynamic>? userContext,
  }) {
    try {
      return resolve(
        streamCode: streamCode,
        directUrl: directUrl,
        posterUrl: posterUrl,
        appId: appId,
        isLive: isLive,
        userContext: userContext,
      );
    } on ArgumentError {
      return null;
    }
  }

  static bool isPlayable({
    String? streamCode,
    String? directUrl,
    String? appId,
  }) {
    final code = streamCode?.trim();
    final resolvedAppId = (appId?.trim().isNotEmpty == true)
        ? appId!.trim()
        : NovaPlayerConfig.appId;
    if (code != null && code.isNotEmpty && resolvedAppId.isNotEmpty) {
      return true;
    }

    final url = directUrl?.trim();
    return url != null &&
        url.isNotEmpty &&
        !NovaPlayerConfig.isNovaHostedMediaUrl(url);
  }

  static bool usesNova(FaithMediaSource source) => source is NovaStreamSource;
}
