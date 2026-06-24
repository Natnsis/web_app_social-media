import 'dart:async';

import 'package:faithconnect/core/media/player/faith_media_player_config.dart';
import 'package:faithconnect/core/media/player/faith_media_player_handle.dart';
import 'package:faithconnect/core/media/player/faith_playback_state.dart';
import 'package:faithconnect/core/media/player/widgets/faith_media_player_overlays.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart' as vp;

/// Progressive / HLS playback via `video_player` when Nova stream codes are absent.
class DirectUrlPlayerSurface extends StatefulWidget {
  final String url;
  final String? posterUrl;
  final FaithMediaPlayerConfig config;
  final bool isActive;
  final void Function(FaithMediaPlayerHandle handle)? onHandleReady;

  const DirectUrlPlayerSurface({
    super.key,
    required this.url,
    this.posterUrl,
    required this.config,
    required this.isActive,
    this.onHandleReady,
  });

  @override
  State<DirectUrlPlayerSurface> createState() => _DirectUrlPlayerSurfaceState();
}

class _DirectUrlPlayerSurfaceState extends State<DirectUrlPlayerSurface>
    with WidgetsBindingObserver {
  vp.VideoPlayerController? _controller;
  final _playbackStateController =
      StreamController<FaithPlaybackState>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();
  final _progressController = StreamController<double>.broadcast();

  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playbackStateController.add(FaithPlaybackState.initializing);
    _initController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onHandleReady?.call(_buildHandle());
    });
  }

  @override
  void didUpdateWidget(DirectUrlPlayerSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _hasError = false;
      _isReady = false;
      _controller?.removeListener(_onTick);
      _controller?.dispose();
      _controller = null;
      _playbackStateController.add(FaithPlaybackState.initializing);
      _initController();
    } else if (oldWidget.isActive != widget.isActive) {
      _applyActiveState();
    }
    if (oldWidget.config.loop != widget.config.loop && _controller != null) {
      _controller!.setLooping(widget.config.loop);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pause();
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      _play();
    }
  }

  FaithMediaPlayerHandle _buildHandle() {
    return FaithMediaPlayerHandle(
      novaController: null,
      play: _play,
      pause: _pause,
      togglePlay: _togglePlay,
      isPlayingStream: _isPlayingController.stream,
      playbackStateStream: _playbackStateController.stream,
      progressStream: _progressController.stream,
      isNovaPowered: false,
    );
  }

  void _initController() {
    final controller = vp.VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: vp.VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    controller.addListener(_onTick);

    controller.initialize().then((_) {
      if (!mounted) return;
      controller.setLooping(widget.config.loop);
      if (widget.config.muteOnStart) {
        controller.setVolume(0);
      }
      setState(() {
        _isReady = true;
        _hasError = false;
      });
      _playbackStateController.add(FaithPlaybackState.paused);
      _applyActiveState();
    }).catchError((Object _) {
      if (!mounted) return;
      setState(() => _hasError = true);
      _playbackStateController.add(FaithPlaybackState.error);
    });
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;
    final playing = controller.value.isPlaying;

    final totalMs = duration.inMilliseconds;
    final progress = totalMs > 0
        ? (position.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;
    _progressController.add(progress);

    _isPlayingController.add(playing);
    _playbackStateController.add(
      playing ? FaithPlaybackState.playing : FaithPlaybackState.paused,
    );
  }

  Future<void> _applyActiveState() async {
    if (!_isReady || _hasError) return;
    if (widget.isActive && widget.config.autoPlayWhenActive) {
      await _play();
    } else {
      await _pause();
    }
  }

  Future<void> _play() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.play();
    _playbackStateController.add(FaithPlaybackState.playing);
  }

  Future<void> _pause() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.pause();
    _playbackStateController.add(FaithPlaybackState.paused);
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await _pause();
    } else {
      await _play();
    }
  }

  double get _progress {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return 0;
    final duration = controller.value.duration;
    if (duration.inMilliseconds <= 0) return 0;
    return (controller.value.position.inMilliseconds / duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onTick);
    _controller?.pause();
    _controller?.dispose();
    _playbackStateController.close();
    _isPlayingController.close();
    _progressController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = !_isReady && !_hasError;

    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        if (!_isReady || _hasError) FaithMediaPoster(posterUrl: widget.posterUrl),
        if (_isReady && !_hasError) _buildVideo(),
        if (isLoading && widget.config.showLoadingIndicator)
          const FaithMediaLoadingOverlay(),
        if (_hasError && widget.config.showErrorOverlay)
          const FaithMediaErrorOverlay(),
        if (_isReady &&
            !_hasError &&
            widget.config.showProgressBar &&
            !widget.config.isLive)
          StreamBuilder<double>(
            stream: _progressController.stream,
            builder: (context, snapshot) {
              return FaithMediaProgressBar(
                progress: snapshot.data ?? _progress,
              );
            },
          ),
        if (widget.config.isLive) const FaithLiveBadge(),
      ],
    );

    final ratio = widget.config.aspectRatio;
    if (ratio != null) {
      content = AspectRatio(aspectRatio: ratio, child: content);
    }

    return content;
  }

  Widget _buildVideo() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: widget.config.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: vp.VideoPlayer(controller),
        ),
      ),
    );
  }
}
