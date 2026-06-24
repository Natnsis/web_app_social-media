import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class CampaignCompletedTile extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;

  const CampaignCompletedTile({
    super.key,
    required this.campaign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedLabel = campaign.completedAt != null
        ? 'Completed ${DateFormat('MMM yyyy').format(campaign.completedAt!)}'
        : 'Completed';

    return AppCompactCard(
      onTap: onTap,
      borderRadius: 20,
      padding: EdgeInsets.all(14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            imageUrl: campaign.avatarUrl,
            size: 48,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  [
                    completedLabel,
                    if (campaign.beneficiaryCount != null)
                      '${campaign.beneficiaryCount} Beneficiaries',
                  ].join(' • '),
                  style: GoogleFonts.inter(
                    color: DarkTheme.feedMutedText,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'TOTAL RAISED',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: DarkTheme.feedMutedText,
                  ),
                ),
                Text(
                  formatCurrencyEtb(campaign.raisedAmountEtb),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: DarkTheme.greenSuccess500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.tick_circle,
                  size: 14.r,
                  color: DarkTheme.greenSuccess500,
                ),
                SizedBox(width: 4.w),
                Text(
                  'SUCCESS',
                  style: GoogleFonts.inter(
                    color: DarkTheme.greenSuccess500,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
