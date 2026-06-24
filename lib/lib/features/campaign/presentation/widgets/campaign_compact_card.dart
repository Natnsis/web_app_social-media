import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CampaignCompactCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;

  const CampaignCompactCard({
    super.key,
    required this.campaign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCompactCard(
      onTap: onTap,
      borderRadius: 20,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              ...campaign.tags.map(
                (tag) => AppTagChip(label: tag),
              ),
              if (campaign.stewardshipTag != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: DarkTheme.greenSuccess500.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.shield_tick,
                        size: 12.r,
                        color: DarkTheme.greenSuccess500,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        campaign.stewardshipTag!,
                        style: GoogleFonts.inter(
                          color: DarkTheme.greenSuccess500,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            campaign.title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            campaign.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: DarkTheme.feedMutedText,
              fontSize: 13.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                '${campaign.progressPercentRounded}% Funded',
                style: GoogleFonts.inter(
                  color: DarkTheme.brandBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${formatCurrencyEtb(campaign.goalAmountEtb)} goal',
                style: GoogleFonts.inter(
                  color: DarkTheme.feedMutedText,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          CampaignProgressBar(progress: campaign.progressPercent / 100),
        ],
      ),
    );
  }
}
