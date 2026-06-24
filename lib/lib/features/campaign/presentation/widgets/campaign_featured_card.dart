import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_amount_row.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignFeaturedCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;

  const CampaignFeaturedCard({
    super.key,
    required this.campaign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCompactCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (campaign.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  campaign.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: DarkTheme.feedTagBackground,
                    child: const Icon(Icons.image_outlined, color: Colors.white24),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18.sp,
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
                SizedBox(height: 14.h),
                CampaignAmountRow(
                  raisedEtb: campaign.raisedAmountEtb,
                  goalEtb: campaign.goalAmountEtb,
                ),
                SizedBox(height: 10.h),
                CampaignProgressBar(
                  progress: campaign.progressPercent / 100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
