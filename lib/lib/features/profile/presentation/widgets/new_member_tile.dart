import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/new_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NewMemberTile extends StatelessWidget {
  final NewMember member;

  const NewMemberTile({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      borderRadius: 20,
      padding: EdgeInsets.all(14.r),
      backgroundColor: DarkTheme.feedCardBackground,
      child: Row(
        children: [
          AppAvatar(imageUrl: member.avatarUrl, size: 48),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: DarkTheme.greenSuccess500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Added ${formatTimeAgo(member.joinedAt)}',
                      style: GoogleFonts.inter(
                        color: DarkTheme.feedMutedText,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
