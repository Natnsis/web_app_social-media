import 'package:faithconnect/core/constants/sample_video_urls.dart';
import 'package:faithconnect/core/media/player/media_player.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:flutter/material.dart';

/// Full-bleed demo live video (shorts-style) with readability gradient.
class LiveWatchFeedBackground extends StatelessWidget {
  final LiveStream stream;
  final int feedIndex;
  final bool isActive;

  const LiveWatchFeedBackground({
    super.key,
    required this.stream,
    required this.feedIndex,
    required this.isActive,
  });

  String get _playbackUrl =>
      stream.playbackUrl ?? SampleVideoUrls.forIndex(feedIndex);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FaithMediaPlayer.live(
          key: ValueKey('live-${stream.id}-${stream.streamCode ?? _playbackUrl}'),
          streamCode: stream.streamCode,
          directUrl: _playbackUrl,
          posterUrl: stream.thumbnailUrl,
          isActive: isActive,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x59000000),
                Colors.transparent,
                Color(0x40000000),
                Color(0xE0000000),
              ],
              stops: [0.0, 0.32, 0.58, 1.0],
            ),
          ),
        ),
        if (!isActive)
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0x66000000)),
          ),
      ],
    );
  }
}

/// Static poster fallback when video is unavailable (detail / watch routes).
class LiveWatchPosterBackground extends StatelessWidget {
  final LiveStream stream;

  const LiveWatchPosterBackground({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    final imageUrl = stream.thumbnailUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const _FallbackBackground(),
          )
        else
          const _FallbackBackground(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.88),
              ],
              stops: const [0.0, 0.35, 0.62, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _FallbackBackground extends StatelessWidget {
  const _FallbackBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: DarkTheme.brandingFallbackGradient,
      ),
      child: Center(
        child: Icon(Icons.live_tv, color: Colors.white24, size: 72),
      ),
    );
  }
}
