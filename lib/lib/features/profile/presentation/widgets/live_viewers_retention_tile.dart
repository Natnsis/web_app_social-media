import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class LiveViewersRetentionTile extends StatelessWidget {
  final String retention;
  final VoidCallback? onTap;

  const LiveViewersRetentionTile({
    super.key,
    required this.retention,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final primary = context.primary;

    return AppSurfaceCard(
      borderRadius: 20,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          _IconBadge(
            icon: Iconsax.clock,
            primary: primary,
            size: 44,
            iconSize: 22,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Retention',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  retention,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          _IconBadge(
            icon: Icons.arrow_forward_ios_rounded,
            primary: primary,
            size: 32,
            iconSize: 14,
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color primary;
  final double size;
  final double iconSize;

  const _IconBadge({
    required this.icon,
    required this.primary,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: primary,
        size: iconSize.sp,
      ),
    );
  }
}
