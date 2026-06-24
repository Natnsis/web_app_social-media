import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileShortClipCard extends StatelessWidget {
  final ProfileShortClip clip;
  final VoidCallback? onTap;
  final bool showManageActions;
  final VoidCallback? onManageTap;

  const ProfileShortClipCard({
    super.key,
    required this.clip,
    this.onTap,
    this.showManageActions = false,
    this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: showManageActions ? onManageTap : null,
        borderRadius: BorderRadius.circular(14.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: colors.cardBackground,
            border: context.isDarkMode
                ? null
                : Border.all(color: colors.divider),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: AspectRatio(
              aspectRatio: 9 / 14,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    clip.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: colors.tagBackground,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: colors.mutedText,
                        size: 28.r,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                        stops: const [0.45, 1],
                      ),
                    ),
                  ),
                  if (showManageActions)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: _ManageButton(onTap: onManageTap),
                    ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _ViewCountBadge(count: clip.viewCount),
                  ),
                  Positioned(
                    left: 10.w,
                    right: 10.w,
                    bottom: 10.h,
                    child: Text(
                      clip.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ManageButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(6.r),
          child: Icon(
            Icons.more_horiz_rounded,
            size: 16.r,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ViewCountBadge extends StatelessWidget {
  final int count;

  const _ViewCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 12.r,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          SizedBox(width: 4.w),
          Text(
            formatCount(count),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
