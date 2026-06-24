import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Owner / administrator summary card below the profile hub header.
class ProfileOwnerCard extends StatelessWidget {
  final ProfileOwner owner;
  final VoidCallback? onMessageTap;

  const ProfileOwnerCard({
    super.key,
    required this.owner,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            colors.brandSky.withValues(alpha: 0.15),
            colors.brandBlue.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: colors.brandSky.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          // Avatar with glowing ring
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colors.brandSky, colors.brandBlue],
              ),
            ),
            child: AppAvatar(
              imageUrl: owner.avatarUrl,
              initials: AppAvatar.initialsFromName(owner.name),
              size: 48,
            ),
          ),

          // ── Gap between avatar and text ──────────────────────────
          SizedBox(width: 14.w),

          // Name
          Expanded(
            child: Text(
              owner.name,
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: 8.w),

          // Role badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.brandSky.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.profile_circle,
                  size: 12.r,
                  color: colors.brandSky,
                ),
                SizedBox(width: 4.w),
                Text(
                  owner.role.isNotEmpty ? owner.role : 'Owner',
                  style: GoogleFonts.inter(
                    color: colors.brandSky,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (onMessageTap != null) ...[
            SizedBox(width: 8.w),
            IconButton(
              onPressed: onMessageTap,
              icon: Icon(Iconsax.message, size: 20.r, color: colors.brandSky),
              style: IconButton.styleFrom(
                backgroundColor: colors.brandSky.withValues(alpha: 0.15),
                padding: EdgeInsets.all(8.r),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
