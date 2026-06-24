import 'dart:io';

import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatAttachmentPreview extends StatelessWidget {
  final ChatMessage message;
  final Color? labelColor;

  const ChatAttachmentPreview({
    super.key,
    required this.message,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!message.hasAttachment) return const SizedBox.shrink();

    final path = message.attachmentPath!;
    final kind = message.attachmentKind ?? MediaUploadKind.image;

    // ── Network URL (received via socket mediaUrl) ─────────────────────────
    final isNetwork =
        path.startsWith('http://') || path.startsWith('https://');

    if (isNetwork) {
      if (kind == MediaUploadKind.video) {
        return _VideoUrlPill(url: path, labelColor: labelColor, context: context);
      }
      return _NetworkImageBubble(url: path);
    }

    // ── Local file (outgoing / optimistic message) ─────────────────────────
    final file = File(path);
    final exists = file.existsSync();
    final name = message.attachmentName?.trim();

    if (kind == MediaUploadKind.image && exists) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 0.65.sw,
            maxHeight: 200.h,
          ),
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final colors = context.faithColors;
    final textColor = labelColor ?? colors.primaryText;

    return Container(
      constraints: BoxConstraints(maxWidth: 0.65.sw),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.tagBackground.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            kind == MediaUploadKind.video
                ? Iconsax.video_play
                : Iconsax.gallery,
            size: 22.r,
            color: textColor,
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              name?.isNotEmpty == true
                  ? name!
                  : (kind == MediaUploadKind.video ? 'Video' : 'Photo'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Network image bubble ────────────────────────────────────────────────────

class _NetworkImageBubble extends StatelessWidget {
  final String url;

  const _NetworkImageBubble({required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.65.sw,
          maxHeight: 220.h,
          minWidth: 80.w,
          minHeight: 60.h,
        ),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          // ── Loading placeholder ────────────────────────────────────────
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            final pct = progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!
                : null;
            return Container(
              color: colors.tagBackground.withValues(alpha: 0.5),
              alignment: Alignment.center,
              child: SizedBox(
                width: 28.r,
                height: 28.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  value: pct,
                  color: colors.brandBlue,
                ),
              ),
            );
          },
          // ── Error fallback ─────────────────────────────────────────────
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: colors.tagBackground.withValues(alpha: 0.4),
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.gallery_slash,
                    size: 28.r,
                    color: colors.mutedText,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Image unavailable',
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Video URL pill (no inline player — just a labelled pill) ────────────────

class _VideoUrlPill extends StatelessWidget {
  final String url;
  final Color? labelColor;
  final BuildContext context;

  const _VideoUrlPill({
    required this.url,
    required this.context,
    this.labelColor,
  });

  @override
  Widget build(BuildContext ctx) {
    final colors = ctx.faithColors;
    final textColor = labelColor ?? colors.primaryText;

    return Container(
      constraints: BoxConstraints(maxWidth: 0.65.sw),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.tagBackground.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.video_play, size: 22.r, color: textColor),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              'Video',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
