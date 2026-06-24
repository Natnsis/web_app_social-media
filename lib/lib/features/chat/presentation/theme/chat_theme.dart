import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

/// Chat-specific colors derived from the active light / dark theme.
class ChatPalette {
  final Color incomingBubble;
  final Color incomingText;
  final Color outgoingBubble;
  final Color outgoingText;
  final Color segmentTrack;
  final LinearGradient segmentActiveGradient;
  final Color moderatorAccent;
  final Color conversationBackground;
  final Color patternColor;

  const ChatPalette({
    required this.incomingBubble,
    required this.incomingText,
    required this.outgoingBubble,
    required this.outgoingText,
    required this.segmentTrack,
    required this.segmentActiveGradient,
    required this.moderatorAccent,
    required this.conversationBackground,
    required this.patternColor,
  });

  static ChatPalette of(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    if (isDark) {
      return ChatPalette(
        incomingBubble: const Color(0xFF1E293B),
        incomingText: colors.primaryText,
        outgoingBubble: const Color(0xFF2B5278),
        outgoingText: const Color(0xFFE8F4FC),
        segmentTrack: const Color(0xFF141820),
        segmentActiveGradient: const LinearGradient(
          colors: [Color(0xFF5EC8FF), Color(0xFF0096FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        moderatorAccent: const Color(0xFFE99B00),
        conversationBackground: const Color(0xFF0E1621),
        patternColor: Colors.white.withValues(alpha: 0.04),
      );
    }

    return ChatPalette(
      incomingBubble: Colors.white,
      incomingText: colors.primaryText,
      outgoingBubble: const Color(0xFFDCF8C6),
      outgoingText: const Color(0xFF0F172A),
      segmentTrack: colors.tagBackground,
      segmentActiveGradient: LinearGradient(
        colors: [colors.brandSky, colors.brandBlue],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      moderatorAccent: const Color(0xFFE99B00),
      conversationBackground: const Color(0xFFE6EBF0),
      patternColor: Colors.black.withValues(alpha: 0.035),
    );
  }
}

extension ChatThemeContext on BuildContext {
  ChatPalette get chatPalette => ChatPalette.of(this);
}
