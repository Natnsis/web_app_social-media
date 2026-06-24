import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthFooterLink extends StatelessWidget {
  final String prefix;
  final String actionLabel;
  final VoidCallback onActionTap;

  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;

    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            color: auth.subtitleColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(text: '$prefix '),
            TextSpan(
              text: actionLabel,
              style: GoogleFonts.inter(
                color: colors.brandBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()..onTap = onActionTap,
            ),
          ],
        ),
      ),
    );
  }
}
