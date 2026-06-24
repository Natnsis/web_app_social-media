import 'package:faithconnect/core/config/env_config.dart';

class MediaUrlResolver {
  static const Set<String> _blockedHosts = {'storage.example.com'};
  static const Set<String> _imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
    '.svg',
    '.avif',
    '.heic',
    '.heif',
  };

  static String? normalize(
    String? rawUrl, {
    bool imageOnly = false,
  }) {
    final candidate = rawUrl?.trim();
    if (candidate == null || candidate.isEmpty) {
      return null;
    }

    if (candidate.startsWith('data:')) {
      return imageOnly && !candidate.startsWith('data:image/') ? null : candidate;
    }

    final parsed = Uri.tryParse(candidate);
    if (parsed == null) {
      return null;
    }

    final Uri resolved;
    if (parsed.hasScheme) {
      if ((parsed.scheme != 'http' && parsed.scheme != 'https') ||
          !_hasUsableHost(parsed)) {
        return null;
      }
      resolved = parsed;
    } else {
      resolved = Uri.parse(EnvConfig.instance.apiBaseUrl).resolveUri(parsed);
    }

    final normalized = resolved.toString();
    if (imageOnly && !_looksLikeImage(normalized)) {
      return null;
    }

    return normalized;
  }

  static bool isNetworkImageUrl(String? rawUrl) =>
      normalize(rawUrl, imageOnly: true) != null;

  static bool isVideoUrl(String? rawUrl) {
    final candidate = rawUrl?.trim();
    if (candidate == null || candidate.isEmpty) return false;
    if (candidate.startsWith('data:video/')) return true;

    final path = Uri.tryParse(candidate)?.path.toLowerCase() ?? candidate.toLowerCase();
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.webm') ||
        path.endsWith('.m3u8') ||
        path.contains('/files/');
  }

  /// Poster/thumbnail URLs must be images — never pass MP4/HLS URLs to [Image.network].
  static String? posterUrl(String? rawUrl) => normalize(rawUrl, imageOnly: true);

  static bool _hasUsableHost(Uri uri) =>
      uri.host.isNotEmpty && !_blockedHosts.contains(uri.host.toLowerCase());

  static bool _looksLikeImage(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.startsWith('data:image/')) {
      return true;
    }

    final path = Uri.tryParse(url)?.path.toLowerCase() ?? lowerUrl;
    return _imageExtensions.any(path.endsWith);
  }
}
