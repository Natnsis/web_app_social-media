import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class GiftsSummaryHeader extends StatelessWidget {
  final GiftSummary summary;

  const GiftsSummaryHeader({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.period.totalLabel,
          style: GoogleFonts.inter(
            color: DarkTheme.feedMutedText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          formatCurrencyEtb(summary.totalAmount),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 36.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: DarkTheme.greenSuccess950.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: DarkTheme.greenSuccess700.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.arrow_up_3,
                size: 14.r,
                color: DarkTheme.greenSuccess400,
              ),
              SizedBox(width: 6.w),
              Text(
                '+${summary.growthPercent.toStringAsFixed(0)}% from last period',
                style: GoogleFonts.inter(
                  color: DarkTheme.greenSuccess400,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
