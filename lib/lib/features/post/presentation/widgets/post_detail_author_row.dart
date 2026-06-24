import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/post/domain/entities/post_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PostDetailAuthorRow extends StatelessWidget {
  final PostDetail detail;
  final VoidCallback onFollowTap;

  const PostDetailAuthorRow({
    super.key,
    required this.detail,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final post = detail.post;
    final meta = detail.locationLabel != null
        ? '${formatTimeAgo(post.createdAt)} • ${detail.locationLabel}'
        : formatTimeAgo(post.createdAt);

    return Row(
      children: [
        InkWell(
          onTap: post.authorProfileId != null
              ? () => context.pushNamed(
                    RoutesConstant.churchProfile,
                    pathParameters: {'id': post.authorProfileId!},
                  )
              : null,
          borderRadius: BorderRadius.circular(999),
          child: AppAvatar(imageUrl: post.authorAvatarUrl, size: 44),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: InkWell(
            onTap: post.authorProfileId != null
                ? () => context.pushNamed(
                      RoutesConstant.churchProfile,
                      pathParameters: {'id': post.authorProfileId!},
                    )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  meta,
                  style: GoogleFonts.inter(
                    color: colors.mutedText,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        PrimaryButton.feedAction(
          text: detail.isFollowingAuthor ? 'Following' : 'Follow',
          onPressed: onFollowTap,
          backgroundColor: detail.isFollowingAuthor
              ? colors.tagBackground
              : null,
          fontSize: 13.sp,
          width: 96.w,
        ),
      ],
    );
  }
}
