import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_feed_background.dart';
import 'package:flutter/material.dart';

/// Full-bleed stream backdrop (poster) for single-stream watch routes.
class LiveWatchBackground extends StatelessWidget {
  final LiveStream stream;

  const LiveWatchBackground({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return LiveWatchPosterBackground(stream: stream);
  }
}
