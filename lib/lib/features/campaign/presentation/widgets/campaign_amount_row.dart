import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignAmountRow extends StatelessWidget {
  final double raisedEtb;
  final double goalEtb;
  final bool largeRaised;

  const CampaignAmountRow({
    super.key,
    required this.raisedEtb,
    required this.goalEtb,
    this.largeRaised = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RAISED',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: DarkTheme.feedMutedText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                formatCurrencyEtb(raisedEtb),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: largeRaised
                      ? DarkTheme.brandBlue
                      : Colors.white,
                  fontSize: largeRaised ? 22.sp : 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'GOAL',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: DarkTheme.feedMutedText,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              formatCurrencyEtb(goalEtb),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: largeRaised ? 16.sp : 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
