import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;
    final disabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(100),
          child: Ink(
            decoration: BoxDecoration(
              gradient: disabled
                  ? LinearGradient(
                      colors: [
                        colors.brandSky.withValues(alpha: 0.4),
                        colors.brandBlue.withValues(alpha: 0.4),
                      ],
                    )
                  : auth.primaryButtonGradient,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
