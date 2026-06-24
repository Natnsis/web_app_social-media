import 'package:faithconnect/core/utils/formatters.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';

/// One row in the chat thread list — either a date chip or a message bubble.
sealed class ChatThreadListEntry {
  const ChatThreadListEntry();
}

final class ChatThreadDateEntry extends ChatThreadListEntry {
  final String label;

  const ChatThreadDateEntry(this.label);
}

final class ChatThreadMessageEntry extends ChatThreadListEntry {
  final ChatMessageLayout layout;

  const ChatThreadMessageEntry(this.layout);
}

/// Layout metadata for a single message in a Telegram-style thread.
class ChatMessageLayout {
  final ChatMessage message;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showSenderHeader;
  final bool showAvatar;

  const ChatMessageLayout({
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.showSenderHeader,
    required this.showAvatar,
  });

  bool get isSingleInGroup => isFirstInGroup && isLastInGroup;
}

const _groupWindow = Duration(minutes: 5);

/// Builds date separators + grouped message layouts for direct and group chats.
List<ChatThreadListEntry> buildChatThreadList(
  List<ChatMessage> messages, {
  required bool isGroup,
}) {
  if (messages.isEmpty) return const [];

  final entries = <ChatThreadListEntry>[];
  String? lastDateLabel;

  for (var i = 0; i < messages.length; i++) {
    final message = messages[i];
    final prev = i > 0 ? messages[i - 1] : null;
    final next = i < messages.length - 1 ? messages[i + 1] : null;

    final dateLabel = formatChatDateSeparator(message.createdAt);
    if (dateLabel != lastDateLabel) {
      entries.add(ChatThreadDateEntry(dateLabel));
      lastDateLabel = dateLabel;
    }

    final firstInGroup = !_continuesFromPrevious(prev, message);
    final lastInGroup = !_continuesToNext(message, next);

    entries.add(
      ChatThreadMessageEntry(
        ChatMessageLayout(
          message: message,
          isFirstInGroup: firstInGroup,
          isLastInGroup: lastInGroup,
          showSenderHeader: isGroup && !message.isMine && firstInGroup,
          showAvatar: !message.isMine && lastInGroup,
        ),
      ),
    );
  }

  return entries;
}

bool _continuesFromPrevious(ChatMessage? earlier, ChatMessage current) {
  if (earlier == null) return false;
  return _sameVisualGroup(earlier, current);
}

bool _continuesToNext(ChatMessage current, ChatMessage? following) {
  if (following == null) return false;
  return _sameVisualGroup(current, following);
}

bool _sameVisualGroup(ChatMessage earlier, ChatMessage later) {
  if (earlier.isReply || later.isReply) return false;
  if (earlier.senderId != later.senderId) return false;
  if (earlier.isMine != later.isMine) return false;

  final gap = later.createdAt.difference(earlier.createdAt);
  if (gap.isNegative || gap > _groupWindow) return false;

  return formatChatDateSeparator(earlier.createdAt) ==
      formatChatDateSeparator(later.createdAt);
}
