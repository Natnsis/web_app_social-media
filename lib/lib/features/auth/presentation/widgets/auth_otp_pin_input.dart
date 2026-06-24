import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

/// Shared 6-digit OTP field — same look as [OtpVerificationSheet].
class AuthOtpPinInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final VoidCallback? onCompleted;

  const AuthOtpPinInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;

    final defaultTheme = PinTheme(
      width: 48.w,
      height: 52.h,
      textStyle: GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: auth.titleColor,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: auth.fieldBorder),
        borderRadius: BorderRadius.circular(12.r),
        color: auth.fieldFill,
      ),
    );

    return Pinput(
      length: 6,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: defaultTheme.copyWith(
        decoration: defaultTheme.decoration?.copyWith(
          border: Border.all(color: colors.brandBlue, width: 2),
        ),
      ),
      onCompleted: onCompleted == null ? null : (_) => onCompleted!(),
    );
  }
}
