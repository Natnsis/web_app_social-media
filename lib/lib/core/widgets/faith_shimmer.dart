import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Theme-aware shimmer wrapper using [FaithAppColors.shimmerBase] / [shimmerHighlight].
class FaithShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const FaithShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Shimmer.fromColors(
      enabled: enabled,
      baseColor: colors.shimmerBase,
      highlightColor: colors.shimmerHighlight,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Solid fill shown through the shimmer mask (use on skeleton shapes).
Color faithShimmerFill(BuildContext context) => context.faithColors.cardBackground;

/// Background behind full-screen skeletons (e.g. shorts, live).
Color faithShimmerScreenFill(BuildContext context) {
  final colors = context.faithColors;
  return context.isDarkMode ? Colors.black : colors.scaffoldBackground;
}
