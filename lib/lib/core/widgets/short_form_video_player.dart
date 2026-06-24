import 'package:faithconnect/core/media/player/media_player.dart';

import 'package:flutter/material.dart';



/// Full-bleed short-form video surface (TikTok-style).

///

/// Thin wrapper around [FaithMediaPlayer] for backward compatibility.

/// Prefer [FaithMediaPlayer.shortForm] for new code.

class ShortFormVideoPlayer extends StatelessWidget {

  final String? videoUrl;

  final String? streamCode;

  final String? novaAppId;

  final String? posterUrl;

  final bool isActive;

  final bool loop;

  final bool showProgressBar;

  final Map<String, dynamic>? userContext;



  const ShortFormVideoPlayer({

    super.key,

    this.videoUrl,

    this.streamCode,

    this.novaAppId,

    this.posterUrl,

    this.isActive = true,

    this.loop = true,

    this.showProgressBar = true,

    this.userContext,

  });



  @override

  Widget build(BuildContext context) {

    final source = FaithMediaSources.tryResolve(
      streamCode: streamCode,
      directUrl: videoUrl,
      posterUrl: posterUrl,
      appId: novaAppId,
      userContext: userContext,
    );



    if (source == null) {

      return FaithMediaPoster(posterUrl: posterUrl);

    }



    return FaithMediaPlayer(

      source: source,

      config: FaithMediaPlayerPresets.shortForm.copyWith(

        loop: loop,

        showProgressBar: showProgressBar,

      ),

      isActive: isActive,

    );

  }

}

