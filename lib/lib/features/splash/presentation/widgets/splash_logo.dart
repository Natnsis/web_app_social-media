import 'package:faithconnect/core/constants/branding_assets.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Theme-aware splash mark: white glyph on dark, brand-blue glyph on light.
class SplashLogo extends StatelessWidget {
  final double size;

  const SplashLogo({super.key, this.size = 132});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    if (context.isDarkMode) {
      return _SplashLogoFrame(
        size: size,
        borderColor: Colors.white.withValues(alpha: 0.22),
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        child: Image.asset(
          BrandingAssets.splashIcon,
          fit: BoxFit.contain,
        ),
      );
    }

    return _SplashLogoFrame(
      size: size,
      borderColor: colors.brandBlue.withValues(alpha: 0.22),
      backgroundColor: Colors.white,
      boxShadow: [
        BoxShadow(
          color: colors.brandBlue.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      child: Image.asset(
        BrandingAssets.splashIcon,
        fit: BoxFit.contain,
        color: colors.brandBlue,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}

class _SplashLogoFrame extends StatelessWidget {
  final double size;
  final Color borderColor;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Widget child;

  const _SplashLogoFrame({
    required this.size,
    required this.borderColor,
    required this.backgroundColor,
    required this.child,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      padding: EdgeInsets.all((size * 0.214).r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
        color: backgroundColor,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
