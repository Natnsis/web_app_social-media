import 'package:faithconnect/core/core.dart';

import 'package:faithconnect/features/post/domain/entities/post_comment.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

class PostCommentTile extends StatelessWidget {

  final PostComment comment;

  final int depth;

  final ValueChanged<PostComment>? onReplyTap;

  final ValueChanged<PostComment>? onLikeTap;

  final ValueChanged<PostComment>? onDeleteTap;
  final ValueChanged<PostComment>? onEditTap;

  final ValueChanged<PostComment>? onLoadRepliesTap;

  final Set<String> loadingReplyParentIds;



  const PostCommentTile({

    super.key,

    required this.comment,

    this.depth = 0,

    this.onReplyTap,

    this.onLikeTap,

    this.onDeleteTap,
    this.onEditTap,

    this.onLoadRepliesTap,

    this.loadingReplyParentIds = const {},

  });



  bool get _isReply => depth > 0;



  bool get _isLoadingReplies => loadingReplyParentIds.contains(comment.id);



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;

    final muted = colors.iconMuted;

    final avatarSize = _isReply ? 32.0 : 40.0;



    final content = Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        AppAvatar(imageUrl: comment.authorAvatarUrl, size: avatarSize),

        SizedBox(width: 12.w),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Expanded(

                    child: Text(

                      comment.authorName,

                      style: GoogleFonts.inter(

                        color: colors.primaryText,

                        fontSize: 14.sp,

                        fontWeight: FontWeight.w700,

                      ),

                    ),

                  ),

                  Text(

                    formatShortTimeAgo(comment.createdAt),

                    style: GoogleFonts.inter(

                      color: muted,

                      fontSize: 12.sp,

                    ),

                  ),

                ],

              ),

              SizedBox(height: 6.h),

              Text(

                comment.text,

                style: GoogleFonts.inter(

                  color: colors.primaryText.withValues(alpha: 0.92),

                  fontSize: 14.sp,

                  height: 1.4,

                ),

              ),

              SizedBox(height: 8.h),

              Row(

                children: [

                  InkWell(

                    onTap:

                        onReplyTap == null ? null : () => onReplyTap!(comment),

                    borderRadius: BorderRadius.circular(4.r),

                    child: Padding(

                      padding: EdgeInsets.symmetric(vertical: 2.h),

                      child: Text(

                        'Reply',

                        style: GoogleFonts.inter(

                          color: muted,

                          fontSize: 13.sp,

                          fontWeight: FontWeight.w600,

                        ),

                      ),

                    ),

                  ),

                  SizedBox(width: 16.w),

                  InkWell(

                    onTap:

                        onLikeTap == null ? null : () => onLikeTap!(comment),

                    borderRadius: BorderRadius.circular(4.r),

                    child: Padding(

                      padding: EdgeInsets.symmetric(vertical: 2.h),

                      child: Row(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Icon(

                            comment.isLiked

                                ? Icons.favorite_rounded

                                : Icons.favorite_border_rounded,

                            size: 16.r,

                            color: comment.isLiked ? Colors.redAccent : muted,

                          ),

                          if (comment.likeCount > 0) ...[

                            SizedBox(width: 4.w),

                            Text(

                              formatCount(comment.likeCount),

                              style: GoogleFonts.inter(

                                color: muted,

                                fontSize: 12.sp,

                              ),

                            ),

                          ],

                        ],

                      ),

                    ),

                  ),

                ],

              ),

            ],

          ),

        ),

      ],

    );



    return Padding(

      padding: EdgeInsets.only(

        bottom: _isReply ? 16.h : 20.h,

        left: _isReply ? 12.w : 0,

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          Builder(
            builder: (gestureContext) => GestureDetector(
              onDoubleTap: () async {
                final box =
                    gestureContext.findRenderObject() as RenderBox?;
                if (box == null) return;
                final position =
                    box.localToGlobal(box.size.center(Offset.zero));
                final action = await showCommentActionMenu(
                  gestureContext,
                  globalPosition: position,
                  isOwned: comment.isOwnedByMe,
                );
                if (action == 'reply' && onReplyTap != null) {
                  onReplyTap!(comment);
                } else if (action == 'delete' && onDeleteTap != null) {
                  onDeleteTap!(comment);
                } else if (action == 'edit' && onEditTap != null) {
                  onEditTap!(comment);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: content,
            ),
          ),

          if (comment.hasMoreReplies && comment.replies.isEmpty)

            _buildLoadRepliesButton(context),

          if (comment.replies.isNotEmpty) _buildRepliesThread(context),

        ],

      ),

    );

  }



  Widget _buildRepliesThread(BuildContext context) {

    return Padding(

      padding: EdgeInsets.only(left: _isReply ? 8.w : 52.w, top: 4.h),

      child: Column(

        children: comment.replies

            .map(

              (reply) => PostCommentTile(

                comment: reply,

                depth: depth + 1,

                onReplyTap: onReplyTap,

                onLikeTap: onLikeTap,

                onDeleteTap: onDeleteTap,
                onEditTap: onEditTap,

                onLoadRepliesTap: onLoadRepliesTap,

                loadingReplyParentIds: loadingReplyParentIds,

              ),

            )

            .toList(),

      ),

    );

  }



  Widget _buildLoadRepliesButton(BuildContext context) {

    final colors = context.faithColors;

    final count = comment.replyCount > 0

        ? comment.replyCount

        : comment.replies.length;

    final indent = 52.w + (depth * 12.w);



    return Padding(

      padding: EdgeInsets.only(left: indent, top: 4.h),

      child: Align(

        alignment: Alignment.centerLeft,

        child: TextButton(

          onPressed: _isLoadingReplies || onLoadRepliesTap == null

              ? null

              : () => onLoadRepliesTap!(comment),

          style: TextButton.styleFrom(

            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),

            minimumSize: Size.zero,

            tapTargetSize: MaterialTapTargetSize.shrinkWrap,

          ),

          child: _isLoadingReplies

              ? SizedBox(

                  width: 16.r,

                  height: 16.r,

                  child: CircularProgressIndicator(

                    strokeWidth: 2,

                    color: colors.brandBlue,

                  ),

                )

              : Text(

                  'View $count ${count == 1 ? 'reply' : 'replies'}',

                  style: GoogleFonts.inter(

                    color: colors.brandBlue,

                    fontSize: 13.sp,

                    fontWeight: FontWeight.w600,

                  ),

                ),

        ),

      ),

    );

  }

}


