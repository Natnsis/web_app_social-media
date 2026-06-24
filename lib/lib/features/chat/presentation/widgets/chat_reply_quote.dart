import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message_reply_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Telegram-style quoted message strip inside a reply bubble.
class ChatReplyQuote extends StatelessWidget {
  final ChatMessageReplyPreview preview;
  final bool isOutgoingBubble;

  const ChatReplyQuote({
    super.key,
    required this.preview,
    required this.isOutgoingBubble,
  });

  bool get _hasImage {
    final url = preview.mediaUrl?.trim() ?? '';
    return url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final accent = preview.isOriginalMine
        ? colors.brandSky
        : (isOutgoingBubble
            ? Colors.white.withValues(alpha: 0.85)
            : colors.brandBlue);

    final displayContent = preview.content.trim().isNotEmpty
        ? preview.content
        : (_hasImage ? '📷 Photo' : '');

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.fromLTRB(8.w, 6.h, _hasImage ? 4.w : 8.w, 6.h),
      decoration: BoxDecoration(
        color: isOutgoingBubble
            ? Colors.black.withValues(alpha: 0.12)
            : colors.tagBackground.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10.r),
        border: Border(
          left: BorderSide(color: accent, width: 3.w),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Text column ────────────────────────────────────────────────
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  preview.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: accent,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayContent,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: isOutgoingBubble
                        ? Colors.white.withValues(alpha: 0.88)
                        : colors.secondaryText,
                    fontSize: 13.sp,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          // ── Image thumbnail ────────────────────────────────────────────
          if (_hasImage) ...[
            SizedBox(width: 8.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: SizedBox(
                width: 44.r,
                height: 44.r,
                child: Image.network(
                  preview.mediaUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: colors.tagBackground.withValues(alpha: 0.5),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 14.r,
                        height: 14.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: colors.brandBlue,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colors.tagBackground.withValues(alpha: 0.4),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 18.r,
                      color: colors.mutedText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
