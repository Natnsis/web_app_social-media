import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';

/// Full-screen background image with theme-aware gradient overlay for onboarding.
class BrandedBackground extends StatelessWidget {
  final String imageAsset;
  final Widget? child;
  final Alignment imageAlignment;
  final BoxFit imageFit;

  const BrandedBackground({
    super.key,
    required this.imageAsset,
    this.child,
    this.imageAlignment = Alignment.center,
    this.imageFit = BoxFit.cover,
  });

  static const LinearGradient _lightOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x33FFFFFF),
      Color(0xD9FFFFFF),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.38, 0.62, 1.0],
  );

  static const LinearGradient _lightFallbackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F4FC),
      Color(0xFFF8FBFF),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final overlay = isDark
        ? DarkTheme.brandingImageOverlayGradient
        : _lightOverlayGradient;
    final fallback = isDark
        ? DarkTheme.brandingFallbackGradient
        : _lightFallbackGradient;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            imageAsset,
            fit: imageFit,
            alignment: imageAlignment,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => DecoratedBox(
              decoration: BoxDecoration(gradient: fallback),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: overlay),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
