import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/presentation/navigation/chat_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMemberTile extends StatelessWidget {
  final GroupMember member;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onBan;

  const GroupMemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onRemove,
    this.onBan,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppCompactCard(
        onTap:
            onTap ??
            () => ChatNavigation.openDirectChat(
              context: context,
              userId: member.userId,
              displayName: member.name,
              avatarUrl: member.avatarUrl,
            ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  imageUrl: member.avatarUrl,
                  initials: AppAvatar.initialsFromName(member.name),
                  size: 38,
                ),
                if (member.isOnline)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50), // Green
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.cardBackground,
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: GoogleFonts.inter(
                          color: colors.primaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (member.role != null &&
                          member.role!.isNotEmpty &&
                          member.role!.toLowerCase() != 'member') ...[
                        SizedBox(width: 8.w),
                        Text(
                          member.role!,
                          style: GoogleFonts.inter(
                            color: colors.brandBlue,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    (member.lastSeenText != null &&
                            member.lastSeenText!.isNotEmpty)
                        ? member.lastSeenText!
                        : 'offline',
                    style: GoogleFonts.inter(
                      color: member.isOnline
                          ? const Color(0xFF4CAF50)
                          : colors.mutedText,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (member.joinedAt != null ||
                (member.role?.isNotEmpty ?? false)) ...[
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (member.role?.isNotEmpty ?? false)
                    Text(
                      member.role!,
                      style: GoogleFonts.inter(
                        color: colors.mutedText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (member.joinedAt != null)
                    Text(
                      'Joined ${_formatDate(member.joinedAt!)}',
                      style: GoogleFonts.inter(
                        color: colors.mutedText,
                        fontSize: 11.sp,
                      ),
                    ),
                ],
              ),
            ],
            if (onRemove != null || onBan != null)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: colors.iconPrimary,
                  size: 20.r,
                ),
                onSelected: (value) {
                  if (value == 'remove') onRemove?.call();
                  if (value == 'ban') onBan?.call();
                },
                itemBuilder: (context) => [
                  if (onRemove != null)
                    PopupMenuItem(
                      value: 'remove',
                      child: Text(
                        'Remove Member',
                        style: GoogleFonts.inter(color: Colors.red),
                      ),
                    ),
                  if (onBan != null)
                    PopupMenuItem(
                      value: 'ban',
                      child: Text(
                        'Ban User',
                        style: GoogleFonts.inter(color: Colors.red),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
