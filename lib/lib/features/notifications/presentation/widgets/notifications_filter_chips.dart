import 'package:faithconnect/core/constants/spacing_radius.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsFilterChips extends StatelessWidget {
  final NotificationFilter selected;
  final int unreadCount;
  final ValueChanged<NotificationFilter> onChanged;

  const NotificationsFilterChips({
    super.key,
    required this.selected,
    required this.unreadCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: selected == NotificationFilter.all,
            onTap: () => onChanged(NotificationFilter.all),
          ),
          AppSpacing.h12,
          _Chip(
            label: 'Unread',
            badge: unreadCount > 0 ? unreadCount : null,
            selected: selected == NotificationFilter.unread,
            onTap: () => onChanged(NotificationFilter.unread),
            glowWhenSelected: true,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int? badge;
  final bool selected;
  final bool glowWhenSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    this.badge,
    required this.selected,
    this.glowWhenSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final gradient = selected && glowWhenSelected
        ? LinearGradient(
            colors: [
              colors.brandSky,
              colors.brandBlue,
              DarkTheme.accent500,
            ],
          )
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: gradient,
          color: selected && gradient == null
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : colors.tagBackground)
              : selected
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : colors.tagBackground.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? (glowWhenSelected
                    ? Colors.transparent
                    : (isDark ? DarkTheme.authCardBorder : colors.divider))
                : (isDark
                    ? DarkTheme.authCardBorder.withValues(alpha: 0.45)
                    : colors.divider),
          ),
          boxShadow: selected && glowWhenSelected && isDark
              ? [
                  BoxShadow(
                    color: colors.brandBlue.withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? colors.primaryText : colors.mutedText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: selected
                      ? (isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : colors.brandSky.withValues(alpha: 0.15))
                      : colors.brandBlue.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$badge',
                  style: GoogleFonts.inter(
                    color: selected ? colors.primaryText : colors.brandSky,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
