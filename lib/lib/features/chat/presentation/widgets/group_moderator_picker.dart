import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class GroupModeratorPicker extends StatelessWidget {
  final List<GroupModeratorCandidate> moderators;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback? onBrowseAll;

  const GroupModeratorPicker({
    super.key,
    required this.moderators,
    required this.selectedIds,
    required this.onToggle,
    this.onBrowseAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Assign Moderators',
              style: GoogleFonts.inter(
                color: DarkTheme.brandBlue.withValues(alpha: 0.85),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onBrowseAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Browse All',
                    style: GoogleFonts.inter(
                      color: DarkTheme.feedMutedText,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Iconsax.search_normal,
                    size: 16.r,
                    color: DarkTheme.feedMutedText,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 188.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: moderators.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final moderator = moderators[index];
              final isSelected = selectedIds.contains(moderator.id);
              return _ModeratorCard(
                moderator: moderator,
                isSelected: isSelected,
                onTap: () => onToggle(moderator.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ModeratorCard extends StatelessWidget {
  final GroupModeratorCandidate moderator;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeratorCard({
    required this.moderator,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCompactCard(
      onTap: onTap,
      borderRadius: 16,
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
      child: SizedBox(
        width: 132.w,
        child: Column(
          children: [
            AppAvatar(
              imageUrl: moderator.avatarUrl,
              size: 52,
            ),
            SizedBox(height: 10.h),
            Text(
              moderator.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              moderator.role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: DarkTheme.feedMutedText,
                fontSize: 12.sp,
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? DarkTheme.brandBlue
                    : DarkTheme.feedTagBackground,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                isSelected ? 'Added' : 'Add',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : DarkTheme.feedMutedText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
