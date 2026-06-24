import 'dart:async';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/gift/presentation/navigation/gift_navigation.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_bloc.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_event.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_state.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_action_rail.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_feed_background.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_chat_overlay.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_composer_bar.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_stream_info.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-screen TikTok-style live room with live chat integration.
class LiveTikTokFeedItem extends StatefulWidget {
  final LiveStream stream;
  final int feedIndex;
  final bool isActive;
  final VoidCallback? onClose;
  final VoidCallback? onGift;

  const LiveTikTokFeedItem({
    super.key,
    required this.stream,
    required this.feedIndex,
    required this.isActive,
    this.onClose,
    this.onGift,
  });

  @override
  State<LiveTikTokFeedItem> createState() => _LiveTikTokFeedItemState();
}

class _LiveTikTokFeedItemState extends State<LiveTikTokFeedItem> {
  final _chatController = TextEditingController();
  bool _isPausedByUser = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _fetchDetails();
    }
  }

  @override
  void didUpdateWidget(LiveTikTokFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _isPausedByUser = false;
      _fetchDetails();
    }
  }

  void _fetchDetails() {
    context.read<LiveStreamBloc>().add(
          LiveStreamDetailRequested(widget.stream.id),
        );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendChat() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    context.read<LiveStreamBloc>().add(
          LiveStreamChatMessageSent(
            streamId: widget.stream.id,
            message: text,
          ),
        );
    _chatController.clear();
  }

  void _onVideoTap() {
    setState(() => _isPausedByUser = !_isPausedByUser);
  }

  bool get _shouldPlayVideo => widget.isActive && !_isPausedByUser;

  void _openGiftPicker(BuildContext context) {
    if (widget.onGift != null) {
      widget.onGift!();
      return;
    }
    GiftNavigation.openLiveGiftSheet(
      context,
      streamId: widget.stream.id,
      hostName: widget.stream.hostName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onVideoTap,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          LiveWatchFeedBackground(
            stream: widget.stream,
            feedIndex: widget.feedIndex,
            isActive: _shouldPlayVideo,
          ),
          if (_isPausedByUser && widget.isActive)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 72,
              ),
            ),
          SafeArea(
            child: BlocBuilder<LiveStreamBloc, LiveStreamState>(
              builder: (context, state) {
                final isLoaded = state is LiveStreamWatchLoaded;
                final messages = isLoaded ? state.chatMessages : const <LiveStreamChatMessage>[];
                final viewerAvatar = isLoaded ? state.viewerAvatarUrl : '';
                final isSending = isLoaded ? state.isSendingChat : false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LiveWatchTopBar(
                      stream: widget.stream,
                      onClose: widget.onClose,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: LiveWatchChatOverlay(messages: messages),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: LiveWatchStreamInfo(stream: widget.stream),
                          ),
                          SizedBox(width: 12.w),
                          LiveWatchActionRail(
                            onGift: () => _openGiftPicker(context),
                            onShare: () => showInfo(context, 'Share coming soon'),
                          ),
                        ],
                      ),
                    ),
                    LiveWatchComposerBar(
                      controller: _chatController,
                      viewerAvatarUrl: viewerAvatar,
                      isSending: isSending,
                      onSend: _sendChat,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
