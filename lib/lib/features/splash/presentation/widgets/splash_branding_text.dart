import 'package:faithconnect/core/config/env_config.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Splash wordmark and tagline typography.
class SplashBrandingText extends StatelessWidget {
  const SplashBrandingText({super.key});

  static const _tagline = 'Digital Sanctuary';

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final appName = EnvConfig.instance.appName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AppNameTitle(
          appName: appName,
          auth: auth,
          accentColor: colors.brandBlue,
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        Text(
          _tagline.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.8,
            height: 1.35,
            color: auth.subtitleColor.withValues(
              alpha: isDark ? 0.95 : 0.88,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Connect in faith, grow in community',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            height: 1.45,
            color: auth.subtitleColor,
          ),
        ),
      ],
    );
  }
}

class _AppNameTitle extends StatelessWidget {
  final String appName;
  final AuthPalette auth;
  final Color accentColor;
  final bool isDark;

  const _AppNameTitle({
    required this.appName,
    required this.auth,
    required this.accentColor,
    required this.isDark,
  });

  TextStyle get _baseStyle => GoogleFonts.plusJakartaSans(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.1,
      );

  @override
  Widget build(BuildContext context) {
    final split = _splitBrandName(appName);

    if (split == null) {
      return Text(
        appName,
        textAlign: TextAlign.center,
        style: _baseStyle.copyWith(
          color: auth.titleColor,
          shadows: isDark ? _titleShadow : null,
        ),
      );
    }

    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        children: [
          TextSpan(
            text: split.$1,
            style: _baseStyle.copyWith(
              color: auth.titleColor,
              shadows: isDark ? _titleShadow : null,
            ),
          ),
          TextSpan(
            text: split.$2,
            style: _baseStyle.copyWith(
              color: isDark ? accentColor.withValues(alpha: 0.95) : accentColor,
              shadows: isDark ? _titleShadow : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Splits names like "FaithConnect" into ("Faith", "Connect").
  (String, String)? _splitBrandName(String name) {
    const suffix = 'Connect';
    if (!name.endsWith(suffix) || name.length <= suffix.length) {
      return null;
    }
    return (name.substring(0, name.length - suffix.length), suffix);
  }

  List<Shadow> get _titleShadow => [
        Shadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
