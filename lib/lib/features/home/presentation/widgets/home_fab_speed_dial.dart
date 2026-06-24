import 'dart:ui';

import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Single speed-dial row (label chip + circular icon).
class HomeFabSpeedDialAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const HomeFabSpeedDialAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

/// Blurred overlay and stacked actions above the home FAB.
class HomeFabSpeedDial extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final List<HomeFabSpeedDialAction> actions;

  const HomeFabSpeedDial({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final scrimColor = isDark
        ? Colors.black.withValues(alpha: isOpen ? 0.45 : 0)
        : Colors.black.withValues(alpha: isOpen ? 0.28 : 0);

    return IgnorePointer(
      ignoring: !isOpen,
      child: AnimatedOpacity(
        opacity: isOpen ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: onClose,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isOpen ? 6 : 0,
                  sigmaY: isOpen ? 6 : 0,
                ),
                child: Container(color: scrimColor),
              ),
            ),
            Positioned(
              right: 20.w,
              bottom: 152.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    _HomeFabSpeedDialItem(action: actions[i]),
                    if (i < actions.length - 1) SizedBox(height: 14.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFabSpeedDialItem extends StatelessWidget {
  final HomeFabSpeedDialAction action;

  const _HomeFabSpeedDialItem({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(10.r),
          elevation: isDark ? 0 : 2,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          child: InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                    : Border.all(color: colors.divider),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                child: Text(
                  action.label,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Material(
          color: colors.brandBlue,
          shape: const CircleBorder(),
          elevation: isDark ? 4 : 3,
          shadowColor: colors.brandBlue.withValues(alpha: 0.35),
          child: InkWell(
            onTap: action.onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 48.r,
              height: 48.r,
              child: Icon(
                action.icon,
                color: Colors.white,
                size: 22.r,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
