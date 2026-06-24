import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/widgets/app_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashed upload area for image / video / short compose screens.
class MediaUploadPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? preview;
  final VoidCallback? onTap;
  final double height;

  const MediaUploadPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.preview,
    this.onTap,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final surfaceColor =
        isDark ? const Color(0xFF1C2129) : colors.cardBackground;
    final borderColor = colors.mutedText.withValues(alpha: isDark ? 0.35 : 0.45);
    final dashedBorderColor = colors.mutedText.withValues(alpha: isDark ? 0.25 : 0.35);
    final iconBgColor = colors.brandBlue.withValues(alpha: isDark ? 0.2 : 0.12);
    final titleColor = colors.primaryText;
    final subtitleColor = colors.mutedText;

    final child = preview != null
        ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: preview!,
              ),
              if (onTap != null)
                Center(
                  child: Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28.r),
                  ),
                ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.brandBlue, size: 28.r),
              ),
              SizedBox(height: 14.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: titleColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: subtitleColor,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          );

    return GestureDetector(
      onTap: onTap ?? () => showInfo(context, 'Upload coming soon'),
      child: Container(
        height: height.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        foregroundDecoration: preview == null
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: dashedBorderColor,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              )
            : null,
        child: child,
      ),
    );
  }
}
