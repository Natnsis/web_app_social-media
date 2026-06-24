import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupJoinRequestTile extends StatelessWidget {
  final GroupJoinRequest request;
  final bool isBusy;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const GroupJoinRequestTile({
    super.key,
    required this.request,
    this.isBusy = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: AppSurfaceCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: request.avatarUrl,
              initials: request.userName.isNotEmpty
                  ? request.userName[0].toUpperCase()
                  : '?',
              size: 44,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: colors.primaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    formatTimeAgo(request.requestedAt),
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (isBusy)
              SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.brandBlue,
                ),
              )
            else ...[
              TextButton(
                onPressed: onReject,
                child: Text(
                  'Reject',
                  style: GoogleFonts.inter(
                    color: colors.mutedText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              FilledButton(
                onPressed: onApprove,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brandBlue,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Approve',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
