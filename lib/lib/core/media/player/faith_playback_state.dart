import 'package:nova_player/nova_player.dart';

/// Unified playback state for Nova and direct-URL backends.
enum FaithPlaybackState {
  idle,
  initializing,
  buffering,
  playing,
  paused,
  ended,
  error,
}

abstract final class FaithPlaybackStateMapper {
  FaithPlaybackStateMapper._();

  static const _novaLoading = {
    PlayBackState.none,
    PlayBackState.initalizing,
    PlayBackState.initalized,
    PlayBackState.buffering,
  };

  static FaithPlaybackState fromNova(PlayBackState state) {
    if (_novaLoading.contains(state)) {
      return state == PlayBackState.buffering
          ? FaithPlaybackState.buffering
          : FaithPlaybackState.initializing;
    }
    return switch (state) {
      PlayBackState.playing => FaithPlaybackState.playing,
      PlayBackState.paused => FaithPlaybackState.paused,
      PlayBackState.finished => FaithPlaybackState.ended,
      PlayBackState.plbackerror => FaithPlaybackState.error,
      _ => FaithPlaybackState.idle,
    };
  }

  static bool isLoading(FaithPlaybackState state) =>
      state == FaithPlaybackState.idle ||
      state == FaithPlaybackState.initializing ||
      state == FaithPlaybackState.buffering;
}
