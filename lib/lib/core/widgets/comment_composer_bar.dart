import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/widgets/app_avatar.dart';
import 'package:faithconnect/core/widgets/custome_text_field.dart';
import 'package:faithconnect/core/widgets/icon_circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Bottom comment row: avatar, pill field, emoji picker, send action.
class CommentComposerBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onSend;
  final ValueChanged<String>? onSubmitted;
  final String? avatarUrl;
  final String hint;
  final bool isSending;

  const CommentComposerBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onSend,
    this.onSubmitted,
    this.avatarUrl,
    this.hint = 'Say something...',
    this.isSending = false,
  });

  @override
  State<CommentComposerBar> createState() => _CommentComposerBarState();
}

class _CommentComposerBarState extends State<CommentComposerBar> {
  late final MessageComposerEmojiController _emojiController;

  @override
  void initState() {
    super.initState();
    _emojiController = MessageComposerEmojiController();
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CommentComposerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _emojiController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode?.hasFocus == true) {
      _emojiController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 12.h),
            decoration: BoxDecoration(
              color: colors.scaffoldBackground,
              border: Border(
                top: BorderSide(
                  color: context.isDarkMode
                      ? colors.tagBackground
                      : colors.divider,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppAvatar(imageUrl: widget.avatarUrl, size: 36),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomMessageTextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    hint: widget.hint,
                    enabled: !widget.isSending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: widget.onSubmitted,
                    emojiController: _emojiController,
                  ),
                ),
                SizedBox(width: 8.w),
                widget.isSending
                    ? SizedBox(
                        width: 44.r,
                        height: 44.r,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.brandBlue,
                          ),
                        ),
                      )
                    : IconCircleButton(
                        icon: Iconsax.send_1,
                        backgroundColor: colors.brandBlue,
                        iconColor: Colors.white,
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
