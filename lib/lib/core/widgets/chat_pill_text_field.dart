import 'package:faithconnect/core/widgets/custome_text_field.dart';
import 'package:flutter/material.dart';

/// Rounded text field for chat composer rows without emoji picker.
class ChatPillTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hint;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final bool enabled;
  final TextInputAction? textInputAction;

  const ChatPillTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint = 'Type a message...',
    this.suffixIcon,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomMessageTextField(
      controller: controller,
      focusNode: focusNode,
      hint: hint,
      enabled: enabled,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      showEmojiButton: false,
    );
  }
}
