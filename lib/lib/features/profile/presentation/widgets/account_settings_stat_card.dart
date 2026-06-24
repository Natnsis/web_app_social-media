import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Metric card for [AccountSettingsPage] (icon, title, value, status line).
class AccountSettingsStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String value;
  final Widget statusLine;
  final VoidCallback? onTap;

  const AccountSettingsStatCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.statusLine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppCompactCard(
      onTap: onTap,
      borderRadius: 24,
      minHeight: 88,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.mutedText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                statusLine,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Green growth label, e.g. "+8% this week".
class AccountSettingsGrowthStatus extends StatelessWidget {
  final String text;

  const AccountSettingsGrowthStatus({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final successColor = Theme.of(context).colorScheme.success;

    return Row(
      children: [
        Icon(
          Iconsax.arrow_up_3,
          size: 12.r,
          color: successColor,
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: successColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Muted subtitle under the stat value.
class AccountSettingsMutedStatus extends StatelessWidget {
  final String text;

  const AccountSettingsMutedStatus({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        color: colors.mutedText,
        fontSize: 12.sp,
        height: 1.25,
      ),
    );
  }
}

/// Live indicator with red dot + label.
class AccountSettingsLiveStatus extends StatelessWidget {
  final String label;

  const AccountSettingsLiveStatus({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Row(
      children: [
        Container(
          width: 7.r,
          height: 7.r,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 12.sp,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
