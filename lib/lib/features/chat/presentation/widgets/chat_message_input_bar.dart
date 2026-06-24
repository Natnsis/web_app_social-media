import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/presentation/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatMessageInputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onSend;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onAttach;
  final String? attachmentName;
  final VoidCallback? onAttachmentRemove;
  final bool isSending;

  const ChatMessageInputBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onSend,
    this.onSubmitted,
    this.onAttach,
    this.attachmentName,
    this.onAttachmentRemove,
    this.isSending = false,
  });

  @override
  State<ChatMessageInputBar> createState() => _ChatMessageInputBarState();
}

class _ChatMessageInputBarState extends State<ChatMessageInputBar> {
  late final MessageComposerEmojiController _emojiController;
  late final FocusNode _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _emojiController = MessageComposerEmojiController();
    _internalFocusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onComposerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onComposerChanged);
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    _emojiController.dispose();
    super.dispose();
  }

  void _onComposerChanged() => setState(() {});

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _emojiController.hide();
    }
  }

  bool get _canSend {
    if (widget.isSending) return false;
    final hasText = widget.controller.text.trim().isNotEmpty;
    final hasAttachment =
        widget.attachmentName != null && widget.attachmentName!.trim().isNotEmpty;
    return hasText || hasAttachment;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final chat = context.chatPalette;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconCircleButton(
                  icon: Iconsax.add_circle,
                  iconColor: colors.mutedText,
                  onPressed: widget.isSending ? null : widget.onAttach,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomMessageTextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: !widget.isSending,
                    textInputAction: TextInputAction.send,
                    onSubmitted: widget.onSubmitted,
                    emojiController: _emojiController,
                    showAttachmentButton: false,
                    attachmentName: widget.attachmentName,
                    onAttachmentRemove: widget.onAttachmentRemove,
                  ),
                ),
                SizedBox(width: 10.w),
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
                        backgroundColor: chat.outgoingBubble,
                        iconColor: chat.outgoingText,
                        onPressed: _canSend ? widget.onSend : null,
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
