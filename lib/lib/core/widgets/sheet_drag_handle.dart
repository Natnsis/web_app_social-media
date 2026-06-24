import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Top grab handle for modal bottom sheets.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 10.h, bottom: 8.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: colors.mutedText.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
