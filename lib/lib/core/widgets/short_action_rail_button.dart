import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vertical action button (like / comment / share) on short-form video.
class ShortActionRailButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? child;
  final bool showIconBackground;

  const ShortActionRailButton({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.iconColor,
    this.child,
    this.showIconBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: showIconBackground
                ? BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  )
                : null,
            alignment: Alignment.center,
            child: child ??
                Icon(
                  icon,
                  color: iconColor ?? Colors.white,
                  size: 26.r,
                ),
          ),
          if (label != null) ...[
            SizedBox(height: 6.h),
            Text(
              label!,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                shadows: showIconBackground
                    ? const [Shadow(color: Colors.black54, blurRadius: 4)]
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
