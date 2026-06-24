import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NewGroupStepHeader extends StatelessWidget {
  const NewGroupStepHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: DarkTheme.brandBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: DarkTheme.brandBlue.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            'Create Group',
            style: GoogleFonts.inter(
              color: DarkTheme.brandBlue,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 3.h,
          width: 72.w,
          decoration: BoxDecoration(
            color: DarkTheme.brandBlue,
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
      ],
    );
  }
}
