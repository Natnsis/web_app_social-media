import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/gift/presentation/navigation/gift_navigation.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_bloc.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_event.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_state.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_action_rail.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_background.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_chat_overlay.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_composer_bar.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_stream_info.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LiveStreamWatchPage extends StatefulWidget {
  final String streamId;

  const LiveStreamWatchPage({super.key, required this.streamId});

  @override
  State<LiveStreamWatchPage> createState() => _LiveStreamWatchPageState();
}

class _LiveStreamWatchPageState extends State<LiveStreamWatchPage> {
  final _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<LiveStreamBloc>()
        .add(LiveStreamDetailRequested(widget.streamId));
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendChat() {
    final text = _chatController.text;
    if (text.trim().isEmpty) return;
    context.read<LiveStreamBloc>().add(
          LiveStreamChatMessageSent(
            streamId: widget.streamId,
            message: text,
          ),
        );
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: BlocConsumer<LiveStreamBloc, LiveStreamState>(
        listener: (context, state) {
          if (state is LiveStreamEnded) {
            showInfo(context, 'Stream ended');
            context.pop();
          } else if (state is LiveStreamFailure) {
            showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is LiveStreamLoading) {
            return const _LiveWatchLoading();
          }

          if (state is LiveStreamWatchLoaded &&
              state.stream.id == widget.streamId) {
            return _LiveWatchContent(
              state: state,
              chatController: _chatController,
              onClose: () => context.pop(),
              onSendChat: _sendChat,
              onGift: () => GiftNavigation.openLiveGiftSheet(
                context,
                streamId: widget.streamId,
                hostName: state.stream.hostName,
              ),
              onShare: () => showInfo(context, 'Share coming soon'),
            );
          }

          if (state is LiveStreamFailure) {
            return Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LiveWatchContent extends StatelessWidget {
  final LiveStreamWatchLoaded state;
  final TextEditingController chatController;
  final VoidCallback onClose;
  final VoidCallback onSendChat;
  final VoidCallback onGift;
  final VoidCallback onShare;

  const _LiveWatchContent({
    required this.state,
    required this.chatController,
    required this.onClose,
    required this.onSendChat,
    required this.onGift,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final stream = state.stream;

    return Stack(
      fit: StackFit.expand,
      children: [
        LiveWatchBackground(stream: stream),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LiveWatchTopBar(stream: stream, onClose: onClose),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: LiveWatchChatOverlay(messages: state.chatMessages),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: LiveWatchStreamInfo(stream: stream),
                    ),
                    SizedBox(width: 12.w),
                    LiveWatchActionRail(
                      onGift: onGift,
                      onShare: onShare,
                    ),
                  ],
                ),
              ),
              LiveWatchComposerBar(
                controller: chatController,
                viewerAvatarUrl: state.viewerAvatarUrl,
                isSending: state.isSendingChat,
                onSend: onSendChat,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveWatchLoading extends StatelessWidget {
  const _LiveWatchLoading();

  @override
  Widget build(BuildContext context) {
    return FaithShimmer(
      child: ColoredBox(color: faithShimmerScreenFill(context)),
    );
  }
}
