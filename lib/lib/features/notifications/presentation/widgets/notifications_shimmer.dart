import 'package:faithconnect/core/constants/spacing_radius.dart';
import 'package:faithconnect/core/widgets/faith_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsShimmer extends StatelessWidget {
  const NotificationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = faithShimmerFill(context);

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.betweenListItems),
          child: FaithShimmer(
            child: Container(
              height: 84.h,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
