import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_progress_bar.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_campaign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoveryCampaignCard extends StatelessWidget {
  final DiscoveryCampaign campaign;
  final VoidCallback? onTap;
  final VoidCallback? onDonateTap;

  const DiscoveryCampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.onDonateTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppCompactCard(
      onTap: onTap,
      borderRadius: 20,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
            Container(
              height: 140.h,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: colors.tagBackground,
                image: DecorationImage(
                  image: NetworkImage(campaign.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${campaign.progressPercentRounded}%',
                style: GoogleFonts.inter(
                  color: colors.brandBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            campaign.organizationName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 14.h),
          CampaignProgressBar(progress: campaign.progress),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatCurrencyEtb(campaign.raisedAmountEtb)} raised of ${formatCurrencyEtb(campaign.goalAmountEtb)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.mutedText,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: colors.tagBackground,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${campaign.daysLeft} days left',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (onDonateTap != null) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton.feedAction(
                text: 'Donate Now',
                onPressed: onDonateTap,
                icon: Icon(Icons.favorite, color: Colors.white, size: 18.r),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
