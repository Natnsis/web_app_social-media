import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:flutter/material.dart';

class LiveStreamPlayer extends StatelessWidget {
  final LiveStream stream;
  final bool isActive;

  const LiveStreamPlayer({
    super.key,
    required this.stream,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playbackUrl = stream.playbackUrl?.trim();
    final hasPlayback =
        (stream.streamCode?.trim().isNotEmpty == true) ||
        (playbackUrl != null && playbackUrl.isNotEmpty);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasPlayback)
              FaithMediaPlayer.embedded(
                streamCode: stream.streamCode,
                directUrl: playbackUrl,
                posterUrl: stream.thumbnailUrl,
                isActive: isActive,
                isLive: stream.isLive,
                controls: const SizedBox.shrink(),
              )
            else
              Icon(
                Icons.live_tv,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            if (stream.isLive)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    'LIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                stream.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
