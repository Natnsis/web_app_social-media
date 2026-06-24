import 'package:faithconnect/core/constants/app_bottom_nav_items.dart';
import 'package:faithconnect/core/layout/shell_tab_scope.dart';
import 'package:faithconnect/core/widgets/short_form_video_player.dart';

import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';

import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_bloc.dart';

import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_state.dart';

import 'package:faithconnect/features/shortvideo/presentation/widgets/short_video_overlay.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';



class ShortVideoPlayerPage extends StatefulWidget {

  final ShortVideo video;

  final int index;

  final bool isActive;

  final VoidCallback onLikeTap;

  final VoidCallback onFollowTap;



  const ShortVideoPlayerPage({

    super.key,

    required this.video,

    required this.index,

    this.isActive = false,

    required this.onLikeTap,

    required this.onFollowTap,

  });



  @override

  State<ShortVideoPlayerPage> createState() => _ShortVideoPlayerPageState();

}



class _ShortVideoPlayerPageState extends State<ShortVideoPlayerPage> {

  bool _isPausedByUser = false;



  bool _isPlaybackAllowed(BuildContext context) {

    final route = ModalRoute.of(context);

    if (route != null && !route.isCurrent) return false;



    final shellScope = ShellTabScope.of(context);

    if (shellScope != null &&

        !shellScope.isTabActive(AppBottomNavItems.shorts.id)) {

      return false;

    }



    return widget.isActive && !_isPausedByUser;

  }



  void _onVideoTap() {

    setState(() => _isPausedByUser = !_isPausedByUser);

  }



  @override

  void didUpdateWidget(ShortVideoPlayerPage oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {

      _isPausedByUser = false;

    }

  }



  @override

  Widget build(BuildContext context) {

    final shouldPlay = _isPlaybackAllowed(context);
    final video = widget.video;

    return GestureDetector(
      onTap: _onVideoTap,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShortFormVideoPlayer(
            key: ValueKey(video.id),
            videoUrl: video.videoUrl,
            streamCode: video.streamCode,
            novaAppId: video.novaAppId,
            posterUrl: video.thumbnailUrl.isNotEmpty
                ? video.thumbnailUrl
                : video.authorAvatarUrl,
            isActive: shouldPlay,
          ),

          const DecoratedBox(

            decoration: BoxDecoration(

              gradient: LinearGradient(

                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [

                  Color(0x59000000),

                  Colors.transparent,

                  Color(0x8C000000),

                ],

                stops: [0, 0.35, 1],

              ),

            ),

          ),

          if (_isPausedByUser && widget.isActive)

            const Center(

              child: Icon(

                Icons.play_circle_fill,

                color: Colors.white70,

                size: 72,

              ),

            ),

          BlocSelector<ShortsFeedBloc, ShortsFeedState, ShortVideo?>(

            selector: (state) {

              if (state is ShortsFeedLoaded &&

                  widget.index >= 0 &&

                  widget.index < state.videos.length) {

                return state.videos[widget.index];

              }

              return null;

            },

            builder: (context, liveVideo) {

              if (liveVideo == null) return const SizedBox.shrink();

              return ShortVideoOverlay(

                video: liveVideo,

                index: widget.index,

                onLikeTap: widget.onLikeTap,

                onFollowTap: widget.onFollowTap,

              );

            },

          ),

        ],

      ),

    );

  }

}


