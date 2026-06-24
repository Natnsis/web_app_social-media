import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveWatchChatMessageRow extends StatelessWidget {
  final LiveStreamChatMessage message;

  const LiveWatchChatMessageRow({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          imageUrl: message.senderAvatarUrl,
          size: 36,
          initials: message.senderName.isNotEmpty
              ? message.senderName[0].toUpperCase()
              : '?',
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: GlassPanel(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            borderRadius: BorderRadius.circular(18.r),
            child: RichText(
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${message.senderName}: ',
                    style: GoogleFonts.inter(
                      color: DarkTheme.brandSky,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  TextSpan(
                    text: message.content,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
