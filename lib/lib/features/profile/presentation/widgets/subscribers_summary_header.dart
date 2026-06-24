import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class SubscribersSummaryHeader extends StatelessWidget {
  final SubscribersSummary summary;

  const SubscribersSummaryHeader({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final formattedTotal = NumberFormat('#,###').format(summary.totalNetwork);
    final formattedPrev =
        NumberFormat('#,###').format(summary.previousPeriodTotal);

    return AppSurfaceCard(
      borderRadius: 24,
      padding: EdgeInsets.all(20.r),
      backgroundColor: DarkTheme.feedCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL NETWORK',
            style: GoogleFonts.inter(
              color: DarkTheme.feedMutedText,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formattedTotal,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: DarkTheme.greenSuccess950.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: DarkTheme.greenSuccess700.withValues(alpha: 0.35),
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
                    SizedBox(width: 4.w),
                    Text(
                      '${summary.growthPercent.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        color: DarkTheme.greenSuccess400,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Growth from $formattedPrev last month',
            style: GoogleFonts.inter(
              color: DarkTheme.feedMutedText,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
