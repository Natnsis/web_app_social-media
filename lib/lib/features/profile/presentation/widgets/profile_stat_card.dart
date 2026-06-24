import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? trendText;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.value,
    this.trendText,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryLine = trendText ?? subtitle;

    return ProfileHubCardShell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ??
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20.r),
              ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                if (secondaryLine != null) ...[
                  SizedBox(height: 6.h),
                  if (trendText != null)
                    Row(
                      children: [
                        Icon(
                          Iconsax.arrow_up_3,
                          size: 12.r,
                          color: DarkTheme.greenSuccess500,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            trendText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: DarkTheme.greenSuccess500,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: DarkTheme.feedMutedText,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 8.w),
            trailing!,
          ],
        ],
      ),
    );
  }
}
