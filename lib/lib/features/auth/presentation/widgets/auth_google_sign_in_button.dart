import 'package:faithconnect/features/auth/presentation/widgets/google_logo_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-width Google sign-in button aligned with [AuthPrimaryButton] styling.
///
/// Uses Google's light button style (white fill, dark label) so it stays
/// readable on both light and dark auth backgrounds.
class AuthGoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AuthGoogleSignInButton({super.key, this.onPressed});

  static const _backgroundColor = Color(0xFFFFFFFF);
  static const _disabledBackgroundColor = Color(0xFFF8F9FA);
  static const _borderColor = Color(0xFFDADCE0);
  static const _textColor = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(100),
          splashColor: const Color(0x1A1F1F1F),
          highlightColor: const Color(0x0D1F1F1F),
          child: Ink(
            decoration: BoxDecoration(
              color: disabled ? _disabledBackgroundColor : _backgroundColor,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _borderColor.withValues(alpha: disabled ? 0.7 : 1),
              ),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 18.w,
                  child: GoogleLogoMark(size: 20.w),
                ),
                Text(
                  'Continue with Google',
                  style: GoogleFonts.roboto(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: _textColor.withValues(alpha: disabled ? 0.45 : 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
