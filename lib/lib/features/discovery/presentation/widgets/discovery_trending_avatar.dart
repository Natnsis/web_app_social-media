import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_trending_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoveryTrendingAvatar extends StatelessWidget {
  final DiscoveryTrendingProfile profile;
  final VoidCallback? onTap;

  const DiscoveryTrendingAvatar({
    super.key,
    required this.profile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 88.w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors.brandBlue,
                    colors.brandSky,
                  ],
                ),
              ),
              child: AppAvatar(
                imageUrl: profile.avatarUrl,
                size: 64,
                initials: profile.name.isNotEmpty ? profile.name[0] : '?',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${formatCount(profile.followerCount)} followers',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: colors.mutedText,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
