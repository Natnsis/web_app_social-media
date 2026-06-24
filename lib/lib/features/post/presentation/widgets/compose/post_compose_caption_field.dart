import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PostComposeCaptionField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const PostComposeCaptionField({
    super.key,
    this.label = 'Caption (optional)',
    this.hint = "What's the story behind this image?",
    required this.controller,
    this.onChanged,
    this.maxLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final cardFill =
        context.isDarkMode ? colors.cardBackground : colors.tagBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: colors.mutedText,
          ),
        ),
        SizedBox(height: 8.h),
        AppSurfaceCard(
          backgroundColor: cardFill,
          borderRadius: 16,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: colors.primaryText,
              height: 1.4,
            ),
            cursorColor: colors.brandBlue,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 15.sp,
                color: colors.mutedText.withValues(alpha: 0.85),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class PostComposeDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PostComposeDescriptionField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final cardFill =
        context.isDarkMode ? colors.cardBackground : colors.tagBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'DESCRIPTION (OPTIONAL)',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: colors.mutedText,
          ),
        ),
        SizedBox(height: 10.h),
        AppSurfaceCard(
          backgroundColor: cardFill,
          borderRadius: 16,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 5,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              color: colors.primaryText,
              height: 1.4,
            ),
            cursorColor: colors.brandBlue,
            decoration: InputDecoration(
              hintText: 'Share the story behind this video...',
              hintStyle: GoogleFonts.inter(
                fontSize: 15.sp,
                color: colors.mutedText.withValues(alpha: 0.85),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
