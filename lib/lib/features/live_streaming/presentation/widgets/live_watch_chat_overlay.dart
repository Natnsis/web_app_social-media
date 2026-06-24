import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_watch_chat_message_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Recent live chat messages with slide/fade-in for new items (TikTok-style).
class LiveWatchChatOverlay extends StatefulWidget {
  final List<LiveStreamChatMessage> messages;
  final int maxVisible;

  const LiveWatchChatOverlay({
    super.key,
    required this.messages,
    this.maxVisible = 5,
  });

  @override
  State<LiveWatchChatOverlay> createState() => _LiveWatchChatOverlayState();
}

class _LiveWatchChatOverlayState extends State<LiveWatchChatOverlay> {
  final _listKey = GlobalKey<AnimatedListState>();
  final List<LiveStreamChatMessage> _visible = [];

  static const _insertDuration = Duration(milliseconds: 380);
  static const _removeDuration = Duration(milliseconds: 260);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _seedInitial());
  }

  @override
  void didUpdateWidget(LiveWatchChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _appendNewMessages(oldWidget.messages, widget.messages);
  }

  void _seedInitial() {
    if (!mounted || widget.messages.isEmpty) return;
    final initial = widget.messages.length <= widget.maxVisible
        ? widget.messages
        : widget.messages.sublist(widget.messages.length - widget.maxVisible);
    for (final message in initial) {
      if (_visible.any((m) => m.id == message.id)) continue;
      _insertAtEnd(message, animate: false);
    }
  }

  void _appendNewMessages(
    List<LiveStreamChatMessage> previous,
    List<LiveStreamChatMessage> next,
  ) {
    final knownIds = previous.map((m) => m.id).toSet();
    for (final message in next) {
      if (knownIds.contains(message.id)) continue;
      if (_visible.any((m) => m.id == message.id)) continue;
      _insertAtEnd(message);
    }
  }

  void _insertAtEnd(LiveStreamChatMessage message, {bool animate = true}) {
    if (!mounted) return;

    if (_visible.length >= widget.maxVisible) {
      _removeAt(0, animate: animate);
    }

    final index = _visible.length;
    _visible.add(message);
    _listKey.currentState?.insertItem(
      index,
      duration: animate ? _insertDuration : Duration.zero,
    );
  }

  void _removeAt(int index, {bool animate = true}) {
    if (index < 0 || index >= _visible.length) return;
    final removed = _visible.removeAt(index);

    if (animate) {
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildAnimatedRow(removed, animation),
        duration: _removeDuration,
      );
    } else {
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildAnimatedRow(removed, animation),
        duration: Duration.zero,
      );
    }
  }

  Widget _buildAnimatedRow(
    LiveStreamChatMessage message,
    Animation<double> animation, {
    bool removing = false,
  }) {
    final slide = Tween<Offset>(
      begin: removing ? Offset.zero : const Offset(0.35, 0),
      end: removing ? const Offset(-0.2, 0) : Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: removing ? Curves.easeIn : Curves.easeOutCubic,
      ),
    );

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: slide,
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: LiveWatchChatMessageRow(message: message),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_visible.isEmpty && widget.messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 72.w, bottom: 8.h),
        child: AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: _visible.length,
          itemBuilder: (context, index, animation) {
            if (index >= _visible.length) return const SizedBox.shrink();
            return _buildAnimatedRow(_visible[index], animation);
          },
        ),
      ),
    );
  }
}
