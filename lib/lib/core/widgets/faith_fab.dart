import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

/// App-branded floating action button (light / dark aware).
class FaithFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool mini;
  final String? heroTag;
  final double? elevation;

  const FaithFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.mini = false,
    this.heroTag,
    this.elevation,
  });

  const FaithFab.mini({
    super.key,
    required this.onPressed,
    required this.child,
    this.heroTag,
    this.elevation,
  }) : mini = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final fabElevation = elevation ?? (isDark ? 6.0 : 4.0);

    return FloatingActionButton(
      heroTag: heroTag,
      mini: mini,
      onPressed: onPressed,
      backgroundColor: colors.brandBlue,
      foregroundColor: Colors.white,
      elevation: fabElevation,
      highlightElevation: fabElevation + 2,
      shape: const CircleBorder(),
      child: child,
    );
  }
}
