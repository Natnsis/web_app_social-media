import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Section title + spaced children for [AccountSettingsPage].
class AccountSettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AccountSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }
}

/// Vertical gap between tiles inside a section.
class AccountSettingsSectionGap extends StatelessWidget {
  const AccountSettingsSectionGap({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(height: 10.h);
}
