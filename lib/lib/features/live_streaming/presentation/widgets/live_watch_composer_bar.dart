import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class LiveWatchComposerBar extends StatefulWidget {
  final TextEditingController controller;
  final String viewerAvatarUrl;
  final VoidCallback onSend;
  final bool isSending;

  const LiveWatchComposerBar({
    super.key,
    required this.controller,
    required this.viewerAvatarUrl,
    required this.onSend,
    this.isSending = false,
  });

  @override
  State<LiveWatchComposerBar> createState() => _LiveWatchComposerBarState();
}

class _LiveWatchComposerBarState extends State<LiveWatchComposerBar> {
  late final MessageComposerEmojiController _emojiController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emojiController = MessageComposerEmojiController();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _emojiController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GlassPanel(
                    padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.h, 6.h),
                    borderRadius: BorderRadius.circular(28.r),
                    tintColor: Colors.black.withValues(alpha: 0.42),
                    child: Row(
                      children: [
                        AppAvatar(
                          imageUrl: widget.viewerAvatarUrl,
                          size: 36,
                          initials: 'Y',
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: CustomMessageTextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            hint: 'Say something...',
                            enabled: !widget.isSending,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) {
                              if (!widget.isSending) widget.onSend();
                            },
                            emojiController: _emojiController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                widget.isSending
                    ? SizedBox(
                        width: 48.r,
                        height: 48.r,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DarkTheme.brandBlue,
                          ),
                        ),
                      )
                    : IconCircleButton(
                        icon: Iconsax.send_1,
                        size: 48,
                        backgroundColor: Colors.transparent,
                        iconColor: DarkTheme.brandBlue,
                        onPressed: widget.onSend,
                      ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: _emojiController,
            builder: (context, _) {
              if (!_emojiController.isVisible) {
                return const SizedBox.shrink();
              }
              return CustomEmojiPickerPanel(
                textController: widget.controller,
                emojiController: _emojiController,
              );
            },
          ),
        ],
      ),
    );
  }
}
