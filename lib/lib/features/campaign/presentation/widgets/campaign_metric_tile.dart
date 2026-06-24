import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const CampaignMetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCompactCard(
      borderRadius: 20,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: Column(
        children: [
          Icon(icon, color: DarkTheme.feedMutedText, size: 22.r),
          SizedBox(height: 8.h),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: DarkTheme.feedMutedText,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
