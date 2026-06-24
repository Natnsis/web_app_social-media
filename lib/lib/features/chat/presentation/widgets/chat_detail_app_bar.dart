import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatRoom room;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBack;
  final VoidCallback? onTitleTap;
  final VoidCallback? onMoreTap;

  const ChatDetailAppBar({
    super.key,
    required this.room,
    this.onMenuTap,
    this.onBack,
    this.onTitleTap,
    this.onMoreTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final iconColor = context.primary;
    final subtitle = room.statusSubtitle ??
        (room.isOnline ? 'Active now' : null);

    return AppBar(
      backgroundColor: colors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: context.faithStatusBarOverlay,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: iconColor,
          size: 20.sp,
        ),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTitleTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: room.avatarUrl,
                  initials: room.initials ??
                      (room.title.isNotEmpty ? room.title[0] : '?'),
                  size: 40,
                  showOnline: room.isOnline,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: colors.headerTitle,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            color: colors.brandBlue,
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (room.isGroup && onMoreTap != null)
          IconButton(
            icon: Icon(Icons.more_horiz, color: iconColor, size: 26.r),
            onPressed: onMoreTap,
          ),
      ],
    );
  }
}
