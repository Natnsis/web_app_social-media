import 'dart:ui';

import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Frosted glass container for overlays on video or imagery.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final Color? borderColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 14,
    this.tintColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20.r);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tintColor ?? Colors.white.withValues(alpha: 0.12),
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? DarkTheme.authCardBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
