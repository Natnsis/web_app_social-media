import 'dart:async';

import 'package:faithconnect/core/media/player/faith_playback_state.dart';
import 'package:nova_player/nova_player.dart';

/// Imperative API exposed to custom control overlays and parent BLoCs.
class FaithMediaPlayerHandle {
  final NovaPlayerController? novaController;
  final Future<void> Function() play;
  final Future<void> Function() pause;
  final Future<void> Function() togglePlay;
  final Stream<bool> isPlayingStream;
  final Stream<FaithPlaybackState> playbackStateStream;
  final Stream<double> progressStream;
  final bool isNovaPowered;

  const FaithMediaPlayerHandle({
    required this.novaController,
    required this.play,
    required this.pause,
    required this.togglePlay,
    required this.isPlayingStream,
    required this.playbackStateStream,
    required this.progressStream,
    required this.isNovaPowered,
  });

  static FaithMediaPlayerHandle noop() {
    return FaithMediaPlayerHandle(
      novaController: null,
      play: _noopAsync,
      pause: _noopAsync,
      togglePlay: _noopAsync,
      isPlayingStream: Stream<bool>.empty(),
      playbackStateStream: Stream<FaithPlaybackState>.empty(),
      progressStream: Stream<double>.empty(),
      isNovaPowered: false,
    );
  }

  static Future<void> _noopAsync() async {}
}
