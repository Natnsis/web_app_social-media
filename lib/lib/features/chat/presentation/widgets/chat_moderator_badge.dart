import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatModeratorBadge extends StatelessWidget {
  const ChatModeratorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: DarkTheme.chatModeratorAccent,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        'MODERATOR',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
