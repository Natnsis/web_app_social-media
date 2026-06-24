import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/utils/formatters.dart';
import 'package:faithconnect/core/constants/save_bookmark_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Like, comment, share, and bookmark row for feed and post detail.
class PostInteractionBar extends StatelessWidget {
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final String? trailingLabel;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onSaveTap;

  const PostInteractionBar({
    super.key,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
    this.isSaved = false,
    this.trailingLabel,
    this.onLikeTap,
    this.onCommentTap,
    this.onShareTap,
    this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final muted = colors.iconMuted;
    final active = colors.brandBlue;
    final likeColor = isLiked ? Colors.redAccent : muted;
    final likeIcon = isLiked
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _MetricButton(
          icon: likeIcon,
          label: isLiked ? formatCount(likeCount) : null,
          color: likeColor,
          onTap: onLikeTap,
        ),
        SizedBox(width: 14.w),
        _MetricButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: formatCount(commentCount),
          color: muted,
          onTap: onCommentTap,
        ),
        const Spacer(),
        if (trailingLabel != null) ...[
          Flexible(
            child: Text(
              trailingLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(fontSize: 13.sp, color: muted),
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            icon: Icon(Icons.share_outlined, size: 22.r, color: muted),
            onPressed: onShareTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ] else ...[
          IconButton(
            icon: Icon(Icons.share_outlined, size: 22.r, color: muted),
            onPressed: onShareTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 8.w),
          IconButton(
            icon: Icon(
              saveBookmarkIcon(isSaved: isSaved),
              size: 22.r,
              color: isSaved ? active : muted,
            ),
            onPressed: onSaveTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ],
    );
  }
}

class _MetricButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback? onTap;

  const _MetricButton({
    required this.icon,
    this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.r, color: color),
            if (label != null) ...[
              SizedBox(width: 4.w),
              Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
