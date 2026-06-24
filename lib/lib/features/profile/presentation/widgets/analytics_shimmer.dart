import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/widgets/faith_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalyticsShimmer extends StatelessWidget {
  const AnalyticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final shimmerFill = faithShimmerFill(context);

    return FaithShimmer(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Total this month title
          Center(
            child: Container(
              height: 14.h,
              width: 120.w,
              decoration: BoxDecoration(
                color: shimmerFill,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Big amount
          Center(
            child: Container(
              height: 48.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: shimmerFill,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Small badge
          Center(
            child: Container(
              height: 24.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: shimmerFill,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          
          // Tabs
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: shimmerFill,
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Chart area
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: shimmerFill,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(height: 32.h),
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: shimmerFill,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: shimmerFill,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          
          // Transactions list title
          Container(
            height: 20.h,
            width: 150.w,
            decoration: BoxDecoration(
              color: shimmerFill,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Transaction items
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Container(
                    height: 48.r,
                    width: 48.r,
                    decoration: BoxDecoration(
                      color: shimmerFill,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: shimmerFill,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 12.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: shimmerFill,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    height: 20.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: shimmerFill,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
