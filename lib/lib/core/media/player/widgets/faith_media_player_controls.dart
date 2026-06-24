import 'package:faithconnect/core/media/player/faith_media_player_handle.dart';
import 'package:faithconnect/core/media/player/nova_player_utils.dart';
import 'package:flutter/material.dart';

/// Default customizable transport controls for embedded / detail layouts.
class FaithMediaPlayerControls extends StatelessWidget {
  final FaithMediaPlayerHandle handle;
  final bool showSeekBar;
  final bool showSkipButtons;
  final Color? iconColor;

  const FaithMediaPlayerControls({
    super.key,
    required this.handle,
    this.showSeekBar = true,
    this.showSkipButtons = true,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: handle.isPlayingStream,
      builder: (context, playSnap) {
        final isReady = playSnap.hasData;
        final isPlaying = playSnap.data ?? false;

        return StreamBuilder<double>(
          stream: handle.progressStream,
          builder: (context, progressSnap) {
            final progress = (progressSnap.data ?? 0).clamp(0.0, 1.0);

            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: isReady
                          ? () => novaPlayerCallAsync(handle.togglePlay)
                          : null,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: iconColor,
                      ),
                    ),
                    if (showSkipButtons) ...[
                      IconButton(
                        onPressed: isReady && handle.isNovaPowered
                            ? () => novaPlayerCallAsync(
                                  () => handle.novaController!.seekRelative(
                                    const Duration(seconds: -10),
                                  ),
                                )
                            : null,
                        icon: Icon(Icons.replay_10, color: iconColor),
                      ),
                      IconButton(
                        onPressed: isReady && handle.isNovaPowered
                            ? () => novaPlayerCallAsync(
                                  () => handle.novaController!.seekRelative(
                                    const Duration(seconds: 10),
                                  ),
                                )
                            : null,
                        icon: Icon(Icons.forward_10, color: iconColor),
                      ),
                    ],
                    if (showSeekBar)
                      Expanded(
                        child: Slider(
                          value: progress,
                          activeColor: iconColor,
                          inactiveColor: Colors.white24,
                          onChanged: isReady && handle.isNovaPowered
                              ? (value) => novaPlayerCallAsync(
                                    () async {
                                      final total = await handle
                                          .novaController!.durationStream
                                          .first;
                                      final seconds = total.inSeconds > 0
                                          ? total.inSeconds
                                          : 1;
                                      await handle.novaController!.seekTo(
                                        Duration(
                                          seconds: (value * seconds).round(),
                                        ),
                                      );
                                    },
                                  )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
