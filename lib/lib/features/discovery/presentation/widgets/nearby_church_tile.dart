import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NearbyChurchTile extends StatelessWidget {
  final DiscoveryNearbyChurch church;
  final VoidCallback? onFollow;
  final VoidCallback? onTap;

  const NearbyChurchTile({
    super.key,
    required this.church,
    this.onFollow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCompactCard(
      onTap: onTap,
      borderRadius: 20,
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              width: 72.w,
              height: 72.w,
              child: church.imageUrl != null
                  ? Image.network(
                      church.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _thumbFallback(),
                    )
                  : _thumbFallback(),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  church.name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 14.r,
                      color: DarkTheme.feedMutedText,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        church.distanceLabel != null
                            ? '${church.location ?? church.address ?? 'Unknown'} • ${church.distanceLabel}'
                            : (church.location ?? church.address ?? 'Unknown location'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: DarkTheme.feedMutedText,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                PrimaryButton.feedAction(
                  text: church.isFollowing ? 'Following' : 'Follow',
                  onPressed: onFollow,
                  width: double.infinity,
                  backgroundColor: church.isFollowing
                      ? DarkTheme.feedTagBackground
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbFallback() {
    return const ColoredBox(
      color: DarkTheme.feedTagBackground,
      child: Center(
        child: Icon(Iconsax.building, color: Colors.white24),
      ),
    );
  }
}
