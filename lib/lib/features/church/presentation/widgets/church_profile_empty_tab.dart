import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChurchProfileEmptyTab extends StatelessWidget {
  final String message;

  const ChurchProfileEmptyTab({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            color: colors.mutedText,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}
