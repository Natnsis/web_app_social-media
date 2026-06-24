import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DiscoveryNearbyCard extends StatelessWidget {
  final DiscoveryNearbyChurch church;
  final VoidCallback? onFollow;
  final VoidCallback? onTap;

  const DiscoveryNearbyCard({
    super.key,
    required this.church,
    this.onFollow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppCompactCard(
      onTap: onTap,
      borderRadius: 16,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(
                imageUrl: church.avatarUrl ?? church.imageUrl,
                size: 36,
                initials: church.name.isNotEmpty ? church.name[0] : '?',
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      church.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 11.r,
                          color: colors.mutedText,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            church.distanceLabel ?? church.location ?? church.address ?? 'Unknown location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: colors.mutedText,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          PrimaryButton(
            text: church.isFollowing ? 'Following' : 'Follow',
            onPressed: onFollow,
            width: double.infinity,
            height: 34.h,
            paddingVertical: 8,
            fontSize: 12.sp,
            backgroundColor:
                church.isFollowing ? colors.tagBackground : colors.brandBlue,
            textColor: church.isFollowing ? colors.primaryText : Colors.white,
            radiusVariant: ButtonRadius.rounded,
          ),
        ],
      ),
    );
  }
}
