import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/domain/entities/following_church.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FollowingChurchTile extends StatelessWidget {
  final FollowingChurch church;
  final VoidCallback? onTap;
  final VoidCallback? onUnfollow;

  const FollowingChurchTile({
    super.key,
    required this.church,
    this.onTap,
    this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppCompactCard(
      onTap: onTap,
      borderRadius: 14,
      minHeight: 0,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: church.displayAvatarUrl != null
                  ? Image.network(
                      church.displayAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _thumbFallback(colors),
                    )
                  : _thumbFallback(colors),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        church.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: colors.primaryText,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (church.isVerified) ...[
                      SizedBox(width: 3.w),
                      Icon(
                        Iconsax.verify,
                        size: 13.r,
                        color: colors.brandSky,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.mutedText,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          PrimaryButton(
            text: 'Unfollow',
            onPressed: onUnfollow,
            height: 30.h,
            paddingVertical: 4,
            paddingHorizontal: 10.w,
            fontSize: 11.sp,
            backgroundColor: colors.tagBackground,
            textColor: colors.primaryText,
            borderColor: colors.mutedText.withValues(alpha: 0.25),
            radiusVariant: ButtonRadius.rounded,
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final parts = <String>[
      if (church.locationLabel.isNotEmpty) church.locationLabel,
      '${formatCount(church.followerCount)} followers',
    ];
    return parts.join(' · ');
  }

  Widget _thumbFallback(FaithAppColors colors) {
    return ColoredBox(
      color: colors.cardBackground,
      child: Center(
        child: Icon(
          Iconsax.building,
          size: 18.r,
          color: colors.mutedText.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
