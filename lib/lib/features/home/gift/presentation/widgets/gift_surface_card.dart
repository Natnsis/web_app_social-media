import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Themed elevated surface for Gift hub and catalog sections.
class GiftSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;

  const GiftSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.backgroundColor,
  });

  static BoxDecoration decoration(
    BuildContext context, {
    double borderRadius = 20,
    Color? backgroundColor,
  }) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final radius = BorderRadius.circular(borderRadius.r);

    return BoxDecoration(
      color: backgroundColor ?? colors.cardBackground,
      borderRadius: radius,
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : colors.divider,
      ),
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: decoration(
        context,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
      ),
      child: child,
    );
  }
}
