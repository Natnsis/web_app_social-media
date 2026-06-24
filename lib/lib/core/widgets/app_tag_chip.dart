import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pill-shaped hashtag or label chip for posts and profiles.
class AppTagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AppTagChip({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final theme = Theme.of(context);

    return Material(
      color: colors.tagBackground,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: context.isDarkMode
                ? null
                : Border.all(color: colors.divider),
          ),
          child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.brandBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ),
      ),
    );
  }
}
