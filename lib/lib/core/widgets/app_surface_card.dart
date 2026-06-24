import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable elevated surface card for lists and tiles.
class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final content = Padding(
      padding: padding ?? EdgeInsets.all(12.r),
      child: child,
    );

    return Material(
      color: backgroundColor ?? colors.cardBackground,
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: content,
      ),
    );
  }
}
