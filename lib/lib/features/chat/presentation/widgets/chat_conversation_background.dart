import 'package:faithconnect/features/chat/presentation/theme/chat_theme.dart';
import 'package:flutter/material.dart';

/// Subtle chat wallpaper behind the message list.
class ChatConversationBackground extends StatelessWidget {
  final Widget child;

  const ChatConversationBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final chat = context.chatPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            chat.conversationBackground,
            Color.alphaBlend(
              chat.patternColor.withValues(alpha: 0.08),
              chat.conversationBackground,
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
