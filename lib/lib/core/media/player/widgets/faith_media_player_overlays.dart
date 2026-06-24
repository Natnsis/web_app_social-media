import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:flutter/material.dart';

class FaithMediaPoster extends StatelessWidget {
  final String? posterUrl;

  const FaithMediaPoster({super.key, this.posterUrl});

  @override
  Widget build(BuildContext context) {
    final url = MediaUrlResolver.posterUrl(posterUrl);
    if (url == null || url.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
    );
  }
}

class FaithMediaLoadingOverlay extends StatelessWidget {
  const FaithMediaLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: DarkTheme.brandBlue,
        strokeWidth: 2,
      ),
    );
  }
}

class FaithMediaErrorOverlay extends StatelessWidget {
  final String message;

  const FaithMediaErrorOverlay({
    super.key,
    this.message = 'Unable to play video',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white54),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class FaithMediaProgressBar extends StatelessWidget {
  final double progress;

  const FaithMediaProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        child: LinearProgressIndicator(
          value: progress > 0 ? progress.clamp(0.0, 1.0) : null,
          minHeight: 3,
          backgroundColor: DarkTheme.feedTagBackground,
          color: DarkTheme.brandBlue,
        ),
      ),
    );
  }
}

class FaithLiveBadge extends StatelessWidget {
  const FaithLiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'LIVE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
