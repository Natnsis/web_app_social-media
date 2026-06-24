import 'package:flutter/material.dart';

/// Layout and behaviour preset for [FaithMediaPlayer].
enum FaithMediaPlayerMode {
  /// Full-bleed vertical short (TikTok / Reels style).
  shortForm,

  /// Full-bleed live room backdrop.
  live,

  /// Card / detail embed (16:9 or custom ratio).
  embedded,
}

class FaithMediaPlayerConfig {
  final FaithMediaPlayerMode mode;
  final BoxFit fit;
  final bool loop;
  final bool showProgressBar;
  final bool showLoadingIndicator;
  final bool showErrorOverlay;
  final double? aspectRatio;
  final bool autoPlayWhenActive;
  final bool muteOnStart;

  const FaithMediaPlayerConfig({
    this.mode = FaithMediaPlayerMode.shortForm,
    this.fit = BoxFit.cover,
    this.loop = true,
    this.showProgressBar = true,
    this.showLoadingIndicator = true,
    this.showErrorOverlay = true,
    this.aspectRatio,
    this.autoPlayWhenActive = true,
    this.muteOnStart = false,
  });

  bool get isLive => mode == FaithMediaPlayerMode.live;

  FaithMediaPlayerConfig copyWith({
    FaithMediaPlayerMode? mode,
    BoxFit? fit,
    bool? loop,
    bool? showProgressBar,
    bool? showLoadingIndicator,
    bool? showErrorOverlay,
    double? aspectRatio,
    bool? autoPlayWhenActive,
    bool? muteOnStart,
  }) {
    return FaithMediaPlayerConfig(
      mode: mode ?? this.mode,
      fit: fit ?? this.fit,
      loop: loop ?? this.loop,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
      showErrorOverlay: showErrorOverlay ?? this.showErrorOverlay,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      autoPlayWhenActive: autoPlayWhenActive ?? this.autoPlayWhenActive,
      muteOnStart: muteOnStart ?? this.muteOnStart,
    );
  }
}

/// Opinionated presets shared by shorts and live surfaces.
abstract final class FaithMediaPlayerPresets {
  FaithMediaPlayerPresets._();

  static const shortForm = FaithMediaPlayerConfig(
    mode: FaithMediaPlayerMode.shortForm,
    fit: BoxFit.cover,
    loop: true,
    showProgressBar: true,
    showLoadingIndicator: true,
  );

  static const live = FaithMediaPlayerConfig(
    mode: FaithMediaPlayerMode.live,
    fit: BoxFit.cover,
    loop: true,
    showProgressBar: false,
    showLoadingIndicator: true,
  );

  static const embedded = FaithMediaPlayerConfig(
    mode: FaithMediaPlayerMode.embedded,
    fit: BoxFit.contain,
    loop: false,
    showProgressBar: true,
    aspectRatio: 16 / 9,
  );
}
