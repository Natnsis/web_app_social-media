import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChurchProfileShimmer extends StatelessWidget {
  const ChurchProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = faithShimmerFill(context);
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return FaithShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 200.h + topInset, color: fill),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 88.r,
                  height: 88.r,
                  decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
                ),
                SizedBox(height: 16.h),
                Container(height: 22.h, width: 220.w, color: fill),
                SizedBox(height: 8.h),
                Container(height: 14.h, width: double.infinity, color: fill),
                SizedBox(height: 24.h),
                Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(16.r),
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
