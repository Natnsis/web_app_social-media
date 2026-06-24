import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_nearby_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal placeholder row while nearby churches load.
class DiscoveryNearbyShimmer extends StatelessWidget {
  const DiscoveryNearbyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = faithShimmerFill(context);

    return FaithShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 3,
        separatorBuilder: (_, _) => SizedBox(
          width: DiscoveryNearbySection.cardGap.w,
        ),
        itemBuilder: (_, _) => _NearbyCardShimmer(fill: fill),
      ),
    );
  }
}

class _NearbyCardShimmer extends StatelessWidget {
  final Color fill;

  const _NearbyCardShimmer({required this.fill});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DiscoveryNearbySection.cardWidth.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12.h,
                      width: double.infinity,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      height: 10.h,
                      width: 100.w,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            height: 34.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }
}
