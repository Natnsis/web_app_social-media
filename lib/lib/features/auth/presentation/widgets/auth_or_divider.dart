import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthOrDivider extends StatelessWidget {
  final String label;

  const AuthOrDivider({super.key, this.label = 'Or login with'});

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: auth.surfaceBorder.withValues(alpha: 0.85),
            height: 1.h,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: auth.subtitleColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: auth.surfaceBorder.withValues(alpha: 0.85),
            height: 1.h,
          ),
        ),
      ],
    );
  }
}
