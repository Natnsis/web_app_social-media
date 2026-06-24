import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uppercase label + borderless text field for compose screens (scripture, etc.).
class AppLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final TextStyle? valueStyle;
  final bool showDivider;

  const AppLabeledField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.onChanged,
    this.maxLines = 1,
    this.valueStyle,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final fieldStyle = valueStyle ??
        GoogleFonts.inter(
          fontSize: maxLines == 1 ? 28.sp : 16.sp,
          fontWeight: maxLines == 1 ? FontWeight.w700 : FontWeight.w400,
          color: maxLines == 1 ? colors.primaryText : colors.mutedText,
          height: 1.35,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: colors.mutedText,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          style: fieldStyle,
          cursorColor: colors.brandBlue,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: fieldStyle.copyWith(
              color: colors.mutedText.withValues(alpha: 0.85),
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (showDivider) ...[
          SizedBox(height: 16.h),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.divider,
          ),
        ],
      ],
    );
  }
}
