import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/domain/home_shell_account_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Church / User dropdown — synced via [HomeShellAccountMode] + prefs.
class AccountModeSwitcher extends StatelessWidget {
  final HomeShellAccountMode mode;
  final ValueChanged<HomeShellAccountMode> onModeChanged;
  final bool showDescription;
  final String? fieldLabel;

  const AccountModeSwitcher({
    super.key,
    required this.mode,
    required this.onModeChanged,
    this.showDescription = false,
    this.fieldLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final theme = Theme.of(context);
    final fillColor = isDark
        ? DarkTheme.sidebarSurface
        : colors.tagBackground;
    final borderColor =
        isDark ? DarkTheme.sidebarSurfaceElevated : colors.divider;
    final textColor = isDark ? Colors.white : colors.primaryText;
    final mutedColor =
        isDark ? DarkTheme.sidebarItemText : colors.mutedText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDescription) ...[
          Text(
            'Switch between managing your church and browsing as a member.',
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
        ],
        if (fieldLabel != null) ...[
          Text(
            fieldLabel!,
            style: GoogleFonts.inter(
              color: mutedColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HomeShellAccountMode>(
              value: mode,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12.r),
              dropdownColor: isDark
                  ? DarkTheme.feedCardBackground
                  : colors.cardBackground,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: mutedColor,
                size: 22.sp,
              ),
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              selectedItemBuilder: (context) {
                return HomeShellAccountMode.values
                    .map(
                      (m) => Align(
                        alignment: Alignment.centerLeft,
                        child: _AccountModeSelectRow(
                          mode: m,
                          textColor: textColor,
                          iconColor: isDark
                              ? DarkTheme.sidebarSelected
                              : colors.brandBlue,
                        ),
                      ),
                    )
                    .toList();
              },
              items: HomeShellAccountMode.values
                  .map(
                    (m) => DropdownMenuItem<HomeShellAccountMode>(
                      value: m,
                      child: _AccountModeSelectRow(
                        mode: m,
                        textColor: isDark
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        iconColor: isDark
                            ? DarkTheme.sidebarSelected
                            : colors.brandBlue,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onModeChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountModeSelectRow extends StatelessWidget {
  final HomeShellAccountMode mode;
  final Color textColor;
  final Color iconColor;

  const _AccountModeSelectRow({
    required this.mode,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final icon = mode == HomeShellAccountMode.church
        ? Icons.church_outlined
        : Icons.person_outline;

    return Row(
      children: [
        Icon(icon, size: 20.sp, color: iconColor),
        SizedBox(width: 10.w),
        Text(
          mode.selectLabel,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
