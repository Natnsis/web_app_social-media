import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_donor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class CampaignDonorRow extends StatelessWidget {
  final CampaignDonor donor;

  const CampaignDonorRow({super.key, required this.donor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: DarkTheme.feedTagBackground,
            child: Icon(
              donor.isAnonymous ? Iconsax.eye_slash : Iconsax.user,
              color: DarkTheme.feedMutedText,
              size: 18.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.displayName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(donor.donatedAt),
                  style: GoogleFonts.inter(
                    color: DarkTheme.feedMutedText,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatCurrencyEtb(donor.amountEtb),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
