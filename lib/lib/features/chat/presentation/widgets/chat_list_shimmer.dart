import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final fill = faithShimmerFill(context);

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => FaithShimmer(
        child: Container(
          height: 76.h,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16.r),
            border: context.isDarkMode
                ? null
                : Border.all(color: colors.divider),
          ),
        ),
      ),
    );
  }
}
