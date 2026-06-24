import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Space-efficient surface card with tight vertical footprint and readable padding.
class AppCompactCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final double? minHeight;

  const AppCompactCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 20,
    this.minHeight,
  });

  /// Default horizontal/vertical inset for compact profile and list cards.
  static EdgeInsetsGeometry compactPadding({bool dense = false}) {
    if (dense) {
      return EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h);
    }
    return EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final radius = BorderRadius.circular(borderRadius.r);
    final content = Padding(
      padding: padding ?? compactPadding(),
      child: child,
    );

    final body = minHeight != null
        ? ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight!.h),
            child: content,
          )
        : content;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.cardBackground,
          borderRadius: radius,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : colors.divider,
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
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: body,
        ),
      ),
    );
  }
}

/// Icon + title + optional subtitle row inside [AppCompactCard].
class AppCompactCardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final bool dense;

  const AppCompactCardTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final iconSize = dense ? 36.0 : 40.0;
    final leadingIconSize = dense ? 20.0 : 22.0;

    return AppCompactCard(
      onTap: onTap,
      padding: AppCompactCard.compactPadding(dense: dense),
      child: Row(
        children: [
          Container(
            width: iconSize.r,
            height: iconSize.r,
            decoration: BoxDecoration(
              color: iconBackgroundColor ??
                  colors.brandBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? colors.brandBlue,
              size: leadingIconSize.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: dense ? 15.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 12.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 8.w),
            trailing!,
          ],
        ],
      ),
    );
  }
}
