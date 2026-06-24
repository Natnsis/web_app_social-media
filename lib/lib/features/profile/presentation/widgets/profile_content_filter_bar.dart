import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Text chips for posts, shorts, campaigns, and events (hub row owns All/grid).
class ProfileContentFilterBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ProfileContentFilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const churchLabels = ['Posts', 'Events', 'Campaigns'];
  static const memberLabels = ['Posts', 'Events', 'Campaigns'];

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;

          return GestureDetector(
            onTap: () {
              if (!selected) onChanged(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: selected ? context.primary : colors.tagBackground,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: selected
                      ? context.primary
                      : (isDark ? Colors.white12 : colors.divider),
                ),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  color: selected ? Colors.white : colors.mutedText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
