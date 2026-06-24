import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: room.avatarUrl,
            initials: room.initials ??
                (room.title.isNotEmpty ? room.title[0] : '?'),
            showOnline: room.isOnline,
            size: 52,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  room.previewText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.mutedText,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                room.timestampLabel,
                style: GoogleFonts.inter(
                  color: colors.mutedText,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (room.isMuted)
                    Icon(
                      Iconsax.notification_status,
                      size: 16.r,
                      color: colors.mutedText,
                    ),
                  if (room.unreadCount > 0) ...[
                    if (room.isMuted) SizedBox(width: 6.w),
                    CountBadge(count: room.unreadCount),
                  ] else if (room.hasUnreadDot) ...[
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: colors.brandBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
