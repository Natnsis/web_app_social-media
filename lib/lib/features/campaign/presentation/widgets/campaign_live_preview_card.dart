import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CampaignLivePreviewCard extends StatelessWidget {
  final NewCampaignDraft draft;

  const CampaignLivePreviewCard({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final title = draft.title.trim().isEmpty
        ? 'Campaign Title Placeholder'
        : draft.title.trim();
    final goal = draft.parsedGoal ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Live Preview',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Iconsax.eye, size: 16.r, color: DarkTheme.feedMutedText),
            SizedBox(width: 4.w),
            Text(
              'Member View',
              style: GoogleFonts.inter(
                color: DarkTheme.feedMutedText,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        AppSurfaceCard(
          borderRadius: 20,
          padding: EdgeInsets.all(14.w),
          backgroundColor: DarkTheme.feedCardBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: DarkTheme.feedTagBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.gallery,
                  color: DarkTheme.feedMutedText,
                  size: 32.r,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    '0 ETB raised',
                    style: GoogleFonts.inter(
                      color: DarkTheme.feedMutedText,
                      fontSize: 12.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '0%',
                    style: GoogleFonts.inter(
                      color: DarkTheme.brandBlue,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              const CampaignProgressBar(progress: 0),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    'Goal: ${formatCurrencyEtb(goal)}',
                    style: GoogleFonts.inter(
                      color: DarkTheme.feedMutedText,
                      fontSize: 12.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '30 days left',
                    style: GoogleFonts.inter(
                      color: DarkTheme.feedMutedText,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              PrimaryButton(
                text: 'Support this Mission',
                onPressed: null,
                isDisabled: true,
                isGradient: true,
                width: double.infinity,
                height: 44.h,
                paddingVertical: 12,
                radiusVariant: ButtonRadius.full,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
