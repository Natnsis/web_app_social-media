import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal tabs with underline indicator (profile, etc.).
class UnderlineTabBar extends StatelessWidget {
  final List<String> labels;
  /// Per-tab icons; `null` entries fall back to [labels] text for that tab.
  final List<IconData?>? icons;
  final List<String>? tooltips;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? indicatorColor;
  final Color? selectedLabelColor;
  final Color? unselectedLabelColor;

  const UnderlineTabBar({
    super.key,
    required this.labels,
    this.icons,
    this.tooltips,
    required this.selectedIndex,
    required this.onChanged,
    this.indicatorColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    final indicator = indicatorColor ?? (isDark ? Colors.white : colors.brandBlue);
    final selectedColor =
        selectedLabelColor ?? (isDark ? Colors.white : colors.brandBlue);
    final unselectedColor = unselectedLabelColor ?? colors.mutedText;

    return SizedBox(
      height: 44.h,
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          final icon = icons != null && index < icons!.length
              ? icons![index]
              : null;
          final tooltip = tooltips != null && index < tooltips!.length
              ? tooltips![index]
              : labels[index];

          Widget tabChild = icon != null
              ? Icon(
                  icon,
                  size: 22.r,
                  color: selected ? selectedColor : unselectedColor,
                )
              : Text(
                  labels[index],
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? selectedColor : unselectedColor,
                  ),
                );

          tabChild = Tooltip(message: tooltip, child: tabChild);

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  tabChild,
                  SizedBox(height: 8.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2.h,
                    width: selected ? 32.w : 0,
                    decoration: BoxDecoration(
                      color: indicator,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
