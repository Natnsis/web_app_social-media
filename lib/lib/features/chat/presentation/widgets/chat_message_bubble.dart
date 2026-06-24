import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_delivery_status.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/presentation/theme/chat_theme.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_attachment_preview.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_moderator_badge.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_read_receipt_icon.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_reply_quote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageLayout layout;
  final ChatRoomType roomType;
  final String? peerAvatarUrl;
  final void Function(ChatMessage message, Offset position)? onLongPress;

  const ChatMessageBubble({
    super.key,
    required this.layout,
    required this.roomType,
    this.peerAvatarUrl,
    this.onLongPress,
  });

  ChatMessage get message => layout.message;

  @override
  Widget build(BuildContext context) {
    if (message.isMine) {
      return _OutgoingBubble(layout: layout, onLongPress: onLongPress);
    }
    return _IncomingBubble(
      layout: layout,
      showSenderHeader: layout.showSenderHeader && roomType == ChatRoomType.group,
      showAvatar: layout.showAvatar,
      peerAvatarUrl: roomType == ChatRoomType.direct ? peerAvatarUrl : null,
      onLongPress: onLongPress,
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  final ChatMessageLayout layout;
  final void Function(ChatMessage message, Offset position)? onLongPress;

  const _OutgoingBubble({
    required this.layout,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatPalette;
    final colors = context.faithColors;
    final message = layout.message;
    final receiptColor = message.deliveryStatus == ChatMessageDeliveryStatus.read
        ? colors.brandBlue
        : chat.outgoingText.withValues(alpha: 0.9);

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onLongPressStart: (details) {
          onLongPress?.call(message, details.globalPosition);
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 0.82.sw),
          child: Container(
            padding: EdgeInsets.fromLTRB(12.w, 8.h, 10.w, 6.h),
            decoration: BoxDecoration(
              color: chat.outgoingBubble,
              borderRadius: _bubbleRadius(isMine: true, layout: layout),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: _BubbleBody(
              message: message,
              textColor: chat.outgoingText,
              timeColor: chat.outgoingText.withValues(alpha: 0.65),
              isOutgoing: true,
              readReceiptColor: receiptColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  final ChatMessageLayout layout;
  final bool showSenderHeader;
  final bool showAvatar;
  final String? peerAvatarUrl;
  final void Function(ChatMessage message, Offset position)? onLongPress;

  const _IncomingBubble({
    required this.layout,
    required this.showSenderHeader,
    required this.showAvatar,
    this.peerAvatarUrl,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final chat = context.chatPalette;
    final colors = context.faithColors;
    final message = layout.message;
    final nameColor =
        message.isModerator ? chat.moderatorAccent : colors.brandBlue;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 36.r,
            child: showAvatar
                ? AppAvatar(
                    imageUrl: message.senderAvatarUrl ?? peerAvatarUrl,
                    size: 32,
                    initials:
                        message.senderName.isNotEmpty ? message.senderName[0] : '?',
                  )
                : null,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSenderHeader) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.senderName,
                          style: GoogleFonts.inter(
                            color: nameColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (message.isModerator) ...[
                          SizedBox(width: 6.w),
                          const ChatModeratorBadge(),
                        ],
                      ],
                    ),
                  ),
                ],
                GestureDetector(
                  onLongPressStart: (details) {
                    onLongPress?.call(message, details.globalPosition);
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 0.75.sw),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(12.w, 8.h, 10.w, 6.h),
                      decoration: BoxDecoration(
                        color: chat.incomingBubble,
                        borderRadius: _bubbleRadius(isMine: false, layout: layout),
                        border: context.isDarkMode
                            ? null
                            : Border.all(
                                color: colors.divider.withValues(alpha: 0.35),
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: _BubbleBody(
                        message: message,
                        textColor: chat.incomingText,
                        timeColor: colors.mutedText,
                        isOutgoing: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final ChatMessage message;
  final Color textColor;
  final Color timeColor;
  final bool isOutgoing;
  final Color? readReceiptColor;

  const _BubbleBody({
    required this.message,
    required this.textColor,
    required this.timeColor,
    required this.isOutgoing,
    this.readReceiptColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = message.content.trim().isNotEmpty;
    final time = formatChatMessageTime(message.createdAt);
    final preview = message.replyPreview;

    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (preview != null)
            ChatReplyQuote(
              preview: preview,
              isOutgoingBubble: isOutgoing,
            ),
          if (message.hasAttachment) ...[
            ChatAttachmentPreview(
              message: message,
              labelColor: textColor,
            ),
            if (hasText) SizedBox(height: 6.h),
          ],
          if (hasText)
            Text(
              message.content,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 15.sp,
                height: 1.35,
              ),
            ),
          SizedBox(height: 2.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                time,
                style: GoogleFonts.inter(
                  color: timeColor,
                  fontSize: 10.sp,
                  height: 1,
                ),
              ),
              if (isOutgoing) ...[
                SizedBox(width: 4.w),
                ChatReadReceiptIcon(
                  status: message.deliveryStatus,
                  color: readReceiptColor ?? timeColor,
                  receipts: message.seenReceipts,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

BorderRadius _bubbleRadius({
  required bool isMine,
  required ChatMessageLayout layout,
}) {
  const large = 16.0;
  const small = 4.0;
  const flat = 6.0;

  if (layout.isSingleInGroup) {
    return isMine
        ? BorderRadius.only(
            topLeft: Radius.circular(large.r),
            topRight: Radius.circular(large.r),
            bottomLeft: Radius.circular(large.r),
            bottomRight: Radius.circular(small.r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(large.r),
            topRight: Radius.circular(large.r),
            bottomLeft: Radius.circular(small.r),
            bottomRight: Radius.circular(large.r),
          );
  }

  if (isMine) {
    return BorderRadius.only(
      topLeft: Radius.circular(
        layout.isFirstInGroup ? large.r : flat.r,
      ),
      topRight: Radius.circular(
        layout.isFirstInGroup ? large.r : flat.r,
      ),
      bottomLeft: Radius.circular(
        layout.isLastInGroup ? large.r : flat.r,
      ),
      bottomRight: Radius.circular(
        layout.isLastInGroup ? small.r : flat.r,
      ),
    );
  }

  return BorderRadius.only(
    topLeft: Radius.circular(
      layout.isFirstInGroup ? large.r : flat.r,
    ),
    topRight: Radius.circular(
      layout.isFirstInGroup ? large.r : flat.r,
    ),
    bottomLeft: Radius.circular(
      layout.isLastInGroup ? small.r : flat.r,
    ),
    bottomRight: Radius.circular(
      layout.isLastInGroup ? large.r : flat.r,
    ),
  );
}
