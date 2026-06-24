import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class LiveViewersPeakCard extends StatelessWidget {
  final LiveViewersSummary summary;

  const LiveViewersPeakCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      borderRadius: 24,
      padding: EdgeInsets.all(20.r),
      backgroundColor: DarkTheme.feedCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S PEAK",
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
                NumberFormat('#,###').format(summary.peakViewers),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: DarkTheme.greenSuccess950.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999.r),
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
                      '+${summary.growthPercent.toStringAsFixed(0)}%',
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
            summary.comparisonLabel,
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
