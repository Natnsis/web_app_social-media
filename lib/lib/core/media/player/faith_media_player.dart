import 'package:faithconnect/core/media/player/faith_media_player_config.dart';
import 'package:faithconnect/core/media/player/faith_media_player_handle.dart';
import 'package:faithconnect/core/media/player/faith_media_source.dart';
import 'package:faithconnect/core/media/player/widgets/direct_url_player_surface.dart';
import 'package:faithconnect/core/media/player/widgets/faith_media_player_controls.dart';
import 'package:faithconnect/core/media/player/widgets/nova_player_surface.dart';
import 'package:flutter/material.dart';
import 'package:nova_player/nova_player.dart' as nova;

/// Reusable media surface for shorts, live streams, and embedded players.
///
/// Picks Nova (`streamCode`) when [NOVA_APP_ID] is configured, otherwise plays
/// direct URLs via `video_player`. Custom controls can be passed or built from
/// [FaithMediaPlayerHandle] via [controlsBuilder].
class FaithMediaPlayer extends StatefulWidget {
  final FaithMediaSource source;
  final FaithMediaPlayerConfig config;
  final bool isActive;
  final nova.NovaPlayerController? novaController;
  final void Function(nova.NovaPlayerController? controller)? onNovaControllerReady;
  final void Function(FaithMediaPlayerHandle handle)? onHandleReady;
  final Widget? controls;
  final Widget Function(BuildContext context, FaithMediaPlayerHandle handle)?
      controlsBuilder;
  final Widget? overlay;

  const FaithMediaPlayer({
    super.key,
    required this.source,
    this.config = FaithMediaPlayerPresets.shortForm,
    this.isActive = true,
    this.novaController,
    this.onNovaControllerReady,
    this.onHandleReady,
    this.controls,
    this.controlsBuilder,
    this.overlay,
  });

  /// Convenience constructor for the most common short-form feed case.
  factory FaithMediaPlayer.shortForm({
    Key? key,
    String? streamCode,
    required String? directUrl,
    String? posterUrl,
    bool isActive = true,
    bool loop = true,
    bool showProgressBar = true,
    Map<String, dynamic>? userContext,
    Widget? overlay,
  }) {
    return FaithMediaPlayer(
      key: key,
      source: FaithMediaSources.resolve(
        streamCode: streamCode,
        directUrl: directUrl,
        posterUrl: posterUrl,
        userContext: userContext,
      ),
      config: FaithMediaPlayerPresets.shortForm.copyWith(
        loop: loop,
        showProgressBar: showProgressBar,
      ),
      isActive: isActive,
      overlay: overlay,
    );
  }

  /// Convenience constructor for live room backdrops.
  factory FaithMediaPlayer.live({
    Key? key,
    String? streamCode,
    required String? directUrl,
    String? posterUrl,
    bool isActive = true,
    Map<String, dynamic>? userContext,
    Widget? overlay,
  }) {
    return FaithMediaPlayer(
      key: key,
      source: FaithMediaSources.resolve(
        streamCode: streamCode,
        directUrl: directUrl,
        posterUrl: posterUrl,
        isLive: true,
        userContext: userContext,
      ),
      config: FaithMediaPlayerPresets.live,
      isActive: isActive,
      overlay: overlay,
    );
  }

  /// Convenience constructor for 16:9 embedded cards.
  factory FaithMediaPlayer.embedded({
    Key? key,
    String? streamCode,
    required String? directUrl,
    String? posterUrl,
    bool isActive = true,
    bool isLive = false,
    Widget? controls,
  }) {
    return FaithMediaPlayer(
      key: key,
      source: FaithMediaSources.resolve(
        streamCode: streamCode,
        directUrl: directUrl,
        posterUrl: posterUrl,
        isLive: isLive,
      ),
      config: FaithMediaPlayerPresets.embedded.copyWith(
        showProgressBar: !isLive,
      ),
      isActive: isActive,
      controls: controls,
    );
  }

  @override
  State<FaithMediaPlayer> createState() => _FaithMediaPlayerState();
}

class _FaithMediaPlayerState extends State<FaithMediaPlayer> {
  FaithMediaPlayerHandle _handle = FaithMediaPlayerHandle.noop();

  void _onHandleReady(FaithMediaPlayerHandle handle) {
    _handle = handle;
    widget.onHandleReady?.call(handle);
    if (widget.controlsBuilder == null && widget.controls == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final controls = widget.controls ??
        widget.controlsBuilder?.call(context, _handle) ??
        (widget.config.mode == FaithMediaPlayerMode.embedded
            ? FaithMediaPlayerControls(handle: _handle)
            : null);

    Widget player = switch (widget.source) {
      NovaStreamSource source => NovaPlayerSurface(
          key: ValueKey('nova-${source.streamCode}'),
          appId: source.appId,
          streamCode: source.streamCode,
          posterUrl: source.posterUrl,
          config: widget.config,
          isActive: widget.isActive,
          userContext: source.userContext,
          controller: widget.novaController,
          onHandleReady: _onHandleReady,
          onControllerReady: widget.onNovaControllerReady,
        ),
      DirectUrlSource source => DirectUrlPlayerSurface(
          key: ValueKey('direct-${source.url}'),
          url: source.url,
          posterUrl: source.posterUrl,
          config: widget.config,
          isActive: widget.isActive,
          onHandleReady: _onHandleReady,
        ),
    };

    if (controls != null || widget.overlay != null) {
      player = Stack(
        fit: StackFit.expand,
        children: [
          player,
          if (controls != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: controls,
            ),
          if (widget.overlay != null) widget.overlay!,
        ],
      );
    }

    return player;
  }
}
