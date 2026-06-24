import 'dart:async';

import 'package:faithconnect/core/media/player/faith_media_player_config.dart';
import 'package:faithconnect/core/media/player/faith_media_player_handle.dart';
import 'package:faithconnect/core/media/player/faith_playback_state.dart';
import 'package:faithconnect/core/media/player/nova_player_utils.dart';
import 'package:faithconnect/core/media/player/widgets/faith_media_player_overlays.dart';
import 'package:flutter/material.dart';
import 'package:nova_player/nova_player.dart' as nova;

/// Nova stream playback via `appId` + `streamCode` ([nova_player.md]).
class NovaPlayerSurface extends StatefulWidget {
  final String appId;
  final String streamCode;
  final String? posterUrl;
  final FaithMediaPlayerConfig config;
  final bool isActive;
  final Map<String, dynamic>? userContext;
  final nova.NovaPlayerController? controller;
  final void Function(FaithMediaPlayerHandle handle)? onHandleReady;
  final void Function(nova.NovaPlayerController controller)? onControllerReady;

  const NovaPlayerSurface({
    super.key,
    required this.appId,
    required this.streamCode,
    this.posterUrl,
    required this.config,
    required this.isActive,
    this.userContext,
    this.controller,
    this.onHandleReady,
    this.onControllerReady,
  });

  @override
  State<NovaPlayerSurface> createState() => _NovaPlayerSurfaceState();
}

class _NovaPlayerSurfaceState extends State<NovaPlayerSurface>
    with WidgetsBindingObserver {
  late nova.NovaPlayerController _controller;
  bool _ownsController = false;
  StreamSubscription<nova.BasePlayerState>? _stateSub;
  StreamSubscription<nova.MediaProgress>? _progressSub;
  StreamSubscription<bool>? _playingSub;

  final _playbackStateController =
      StreamController<FaithPlaybackState>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();
  final _progressValueController = StreamController<double>.broadcast();

  FaithPlaybackState _playbackState = FaithPlaybackState.initializing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bindController(widget.controller ?? _createController());
    _playbackStateController.add(_playbackState);
  }

  nova.NovaPlayerController _createController() {
    _ownsController = true;
    return nova.NovaPlayerController();
  }

  void _bindController(nova.NovaPlayerController controller) {
    _controller = controller;
    widget.onControllerReady?.call(controller);

    _stateSub = _controller.playerStateStream.listen((state) {
      final mapped = FaithPlaybackStateMapper.fromNova(state.playBackState);
      if (_playbackState != mapped) {
        _playbackState = mapped;
        _playbackStateController.add(mapped);
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }
      }
    });

    _playingSub = _controller.isPlayingStream.listen(_isPlayingController.add);

    _progressSub = _controller.mediaProgressStream.listen((progress) {
      final totalMs = progress.totalDuration.inMilliseconds;
      final value = totalMs > 0
          ? (progress.progress.inMilliseconds / totalMs).clamp(0.0, 1.0)
          : 0.0;
      _progressValueController.add(value);
    });

    _notifyHandleReady();
    _applyActiveState();
  }

  void _notifyHandleReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onHandleReady?.call(_buildHandle());
    });
  }

  FaithMediaPlayerHandle _buildHandle() {
    return FaithMediaPlayerHandle(
      novaController: _controller,
      play: () => novaPlayerCallAsync(_controller.play),
      pause: () => novaPlayerCallAsync(_controller.pause),
      togglePlay: () => novaPlayerCallAsync(_controller.togglePlay),
      isPlayingStream: _isPlayingController.stream,
      playbackStateStream: _playbackStateController.stream,
      progressStream: _progressValueController.stream,
      isNovaPowered: true,
    );
  }

  @override
  void didUpdateWidget(NovaPlayerSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamCode != widget.streamCode ||
        oldWidget.appId != widget.appId) {
      _resetForNewStream();
    } else if (oldWidget.isActive != widget.isActive) {
      _applyActiveState();
    }
  }

  void _resetForNewStream() {
    _stateSub?.cancel();
    _playingSub?.cancel();
    _progressSub?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    _playbackState = FaithPlaybackState.initializing;
    _bindController(_createController());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      novaPlayerCallAsync(_controller.pause);
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      _applyActiveState();
    }
  }

  void _applyActiveState() {
    if (!widget.config.autoPlayWhenActive) return;
    if (widget.isActive) {
      novaPlayerCallAsync(_controller.play);
    } else {
      novaPlayerCallAsync(_controller.pause);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateSub?.cancel();
    _playingSub?.cancel();
    _progressSub?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    _playbackStateController.close();
    _isPlayingController.close();
    _progressValueController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = FaithPlaybackStateMapper.isLoading(_playbackState);
    final hasError = _playbackState == FaithPlaybackState.error;

    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        nova.VideoPlayer(
          appId: widget.appId,
          streamCode: widget.streamCode,
          controller: _controller,
          controls: const SizedBox.shrink(),
          userContext: widget.userContext,
        ),
        if (isLoading) FaithMediaPoster(posterUrl: widget.posterUrl),
        if (isLoading && widget.config.showLoadingIndicator)
          const FaithMediaLoadingOverlay(),
        if (hasError && widget.config.showErrorOverlay)
          const FaithMediaErrorOverlay(),
        if (widget.config.isLive) const FaithLiveBadge(),
      ],
    );

    final ratio = widget.config.aspectRatio;
    if (ratio != null) {
      content = AspectRatio(aspectRatio: ratio, child: content);
    }

    return content;
  }
}
