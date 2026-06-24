import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignGivingOptionsCard extends StatelessWidget {
  final bool allowAnonymous;
  final bool showProgressPublicly;
  final ValueChanged<bool> onAnonymousChanged;
  final ValueChanged<bool> onShowProgressChanged;

  const CampaignGivingOptionsCard({
    super.key,
    required this.allowAnonymous,
    required this.showProgressPublicly,
    required this.onAnonymousChanged,
    required this.onShowProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      borderRadius: 20,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      backgroundColor: DarkTheme.feedCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
            child: Text(
              'Giving Options',
              style: GoogleFonts.inter(
                color: DarkTheme.brandBlue.withValues(alpha: 0.85),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSettingsSwitchTile(
            title: 'Allow Anonymous Giving',
            subtitle:
                'Donors can choose to hide their names from others.',
            value: allowAnonymous,
            onChanged: onAnonymousChanged,
          ),
          AppSettingsSwitchTile(
            title: 'Show Progress Publicly',
            subtitle:
                'Display the total amount raised on the campaign page.',
            value: showProgressPublicly,
            onChanged: onShowProgressChanged,
          ),
        ],
      ),
    );
  }
}
