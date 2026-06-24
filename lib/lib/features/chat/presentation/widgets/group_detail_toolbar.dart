import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum GroupDetailSection { members, search, addMember }

/// Action strip on a single group's detail page.
class GroupDetailToolbar extends StatelessWidget {
  final int memberCount;
  final GroupDetailSection selectedSection;
  final bool showAdminActions;
  final ValueChanged<GroupDetailSection> onSectionChanged;

  const GroupDetailToolbar({
    super.key,
    required this.memberCount,
    required this.selectedSection,
    required this.onSectionChanged,
    this.showAdminActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final countLabel =
        '$memberCount member${memberCount == 1 ? '' : 's'}';

    return Material(
      color: colors.cardBackground,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.divider.withValues(alpha: 0.45)),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              _ActionChip(
                icon: Iconsax.people,
                label: countLabel,
                isActive: selectedSection == GroupDetailSection.members,
                onTap: () => onSectionChanged(GroupDetailSection.members),
              ),
              if (showAdminActions) ...[
                SizedBox(width: 8.w),
                _ActionChip(
                  icon: Iconsax.search_normal,
                  label: 'Search',
                  isActive: selectedSection == GroupDetailSection.search,
                  onTap: () => onSectionChanged(GroupDetailSection.search),
                ),
                SizedBox(width: 8.w),
                _ActionChip(
                  icon: Iconsax.user_add,
                  label: 'Add Member',
                  isActive: selectedSection == GroupDetailSection.addMember,
                  accent: selectedSection == GroupDetailSection.addMember,
                  onTap: () => onSectionChanged(GroupDetailSection.addMember),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GroupDetailSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback? onClear;

  const GroupDetailSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText = 'Search members…',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: GoogleFonts.inter(color: colors.primaryText, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: colors.mutedText, fontSize: 14.sp),
          prefixIcon: Icon(Iconsax.search_normal, size: 18.r, color: colors.mutedText),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, size: 18.r, color: colors.mutedText),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: colors.cardBackground,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colors.divider.withValues(alpha: 0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colors.brandBlue),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final bool accent;

  const _ActionChip({
    this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final foreground = (isActive || accent) ? colors.brandBlue : colors.primaryText;
    final background = isActive
        ? colors.brandBlue.withValues(alpha: 0.12)
        : colors.tagBackground.withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20.r),
            border: isActive
                ? Border.all(color: colors.brandBlue.withValues(alpha: 0.35))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.r, color: foreground),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  color: foreground,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
