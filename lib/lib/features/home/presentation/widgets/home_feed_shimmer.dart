import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeFeedShimmer extends StatelessWidget {
  const HomeFeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = faithShimmerFill(context);

    return FaithShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          _shimmerRow(context, height: 80.h, fill: fill),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _shimmerBox(height: 140.h, radius: AppRadius.lg, fill: fill),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _shimmerBox(height: 320.h, radius: AppRadius.base, fill: fill),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _shimmerBox(height: 280.h, radius: AppRadius.base, fill: fill),
          ),
        ],
      ),
    );
  }

  Widget _shimmerRow(
    BuildContext context, {
    required double height,
    required Color fill,
  }) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) => Container(
          width: 64.r,
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    required double radius,
    required Color fill,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}
