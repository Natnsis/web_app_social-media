import 'package:faithconnect/core/core.dart';

import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';


class ReflectionTile extends StatelessWidget {

  final Reflection reflection;

  final int depth;

  final ValueChanged<Reflection>? onReplyTap;

  final ValueChanged<Reflection>? onLikeTap;

  final ValueChanged<Reflection>? onDeleteTap;

  final ValueChanged<Reflection>? onEditTap;

  final ValueChanged<Reflection>? onLoadRepliesTap;

  final Set<String> loadingReplyParentIds;



  const ReflectionTile({

    super.key,

    required this.reflection,

    this.depth = 0,

    this.onReplyTap,

    this.onLikeTap,

    this.onDeleteTap,

    this.onEditTap,

    this.onLoadRepliesTap,

    this.loadingReplyParentIds = const {},

  });



  bool get _isReply => depth > 0;



  bool get _isLoadingReplies =>

      loadingReplyParentIds.contains(reflection.id);



  @override

  Widget build(BuildContext context) {

    final content = Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        AppAvatar(

          imageUrl: reflection.authorAvatarUrl,

          size: _isReply ? 32 : 40,

        ),

        SizedBox(width: 12.w),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Expanded(

                    child: Text(

                      reflection.authorName,

                      style: GoogleFonts.inter(

                        color: DarkTheme.brandSky,

                        fontSize: 14.sp,

                        fontWeight: FontWeight.w700,

                      ),

                    ),

                  ),

                  Text(

                    formatShortTimeAgo(reflection.createdAt),

                    style: GoogleFonts.inter(

                      color: DarkTheme.feedMutedText,

                      fontSize: 12.sp,

                    ),

                  ),

                ],

              ),

              SizedBox(height: 6.h),

              Text(

                reflection.text,

                style: GoogleFonts.inter(

                  color: Colors.white.withValues(alpha: 0.92),

                  fontSize: 14.sp,

                  height: 1.45,

                ),

              ),

              SizedBox(height: 8.h),

              Row(

                children: [

                  InkWell(

                    onTap: onLikeTap == null

                        ? null

                        : () => onLikeTap!(reflection),

                    borderRadius: BorderRadius.circular(4.r),

                    child: Padding(

                      padding: EdgeInsets.symmetric(vertical: 2.h),

                      child: Row(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Icon(

                            reflection.isLiked

                                ? Icons.favorite_rounded

                                : Icons.favorite_border_rounded,

                            size: 16.r,

                            color: reflection.isLiked

                                ? Colors.redAccent

                                : DarkTheme.feedMutedText,

                          ),

                          if (reflection.likeCount > 0) ...[

                            SizedBox(width: 4.w),

                            Text(

                              formatCount(reflection.likeCount),

                              style: GoogleFonts.inter(

                                color: DarkTheme.feedMutedText,

                                fontSize: 12.sp,

                              ),

                            ),

                          ],

                        ],

                      ),

                    ),

                  ),

                  SizedBox(width: 16.w),

                  InkWell(

                    onTap: onReplyTap == null

                        ? null

                        : () => onReplyTap!(reflection),

                    borderRadius: BorderRadius.circular(4.r),

                    child: Padding(

                      padding: EdgeInsets.symmetric(vertical: 2.h),

                      child: Row(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Icon(

                            Iconsax.arrow_left_2,

                            size: 14.r,

                            color: DarkTheme.feedMutedText,

                          ),

                          SizedBox(width: 4.w),

                          Text(

                            'Reply',

                            style: GoogleFonts.inter(

                              color: DarkTheme.feedMutedText,

                              fontSize: 13.sp,

                              fontWeight: FontWeight.w600,

                            ),

                          ),

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
                  isOwned: reflection.isOwnedByMe,
                );
                if (action == 'reply' && onReplyTap != null) {
                  onReplyTap!(reflection);
                } else if (action == 'edit' && onEditTap != null) {
                  onEditTap!(reflection);
                } else if (action == 'delete' && onDeleteTap != null) {
                  onDeleteTap!(reflection);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: content,
            ),
          ),

          if (reflection.hasMoreReplies && reflection.replies.isEmpty)

            _buildLoadRepliesButton(),

          if (reflection.replies.isNotEmpty) _buildRepliesThread(),

        ],

      ),

    );

  }



  Widget _buildRepliesThread() {

    return Padding(

      padding: EdgeInsets.only(left: _isReply ? 8.w : 52.w, top: 4.h),

      child: Column(

        children: reflection.replies

            .map(

              (reply) => ReflectionTile(

                reflection: reply,

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



  Widget _buildLoadRepliesButton() {

    final count = reflection.replyCount > 0

        ? reflection.replyCount

        : reflection.replies.length;

    final indent = 52.w + (depth * 12.w);



    return Padding(

      padding: EdgeInsets.only(left: indent, top: 4.h),

      child: Align(

        alignment: Alignment.centerLeft,

        child: TextButton(

          onPressed: _isLoadingReplies || onLoadRepliesTap == null

              ? null

              : () => onLoadRepliesTap!(reflection),

          style: TextButton.styleFrom(

            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),

            minimumSize: Size.zero,

            tapTargetSize: MaterialTapTargetSize.shrinkWrap,

          ),

          child: _isLoadingReplies

              ? SizedBox(

                  width: 16.r,

                  height: 16.r,

                  child: const CircularProgressIndicator(

                    strokeWidth: 2,

                    color: DarkTheme.brandBlue,

                  ),

                )

              : Text(

                  'View $count ${count == 1 ? 'reply' : 'replies'}',

                  style: GoogleFonts.inter(

                    color: DarkTheme.brandBlue,

                    fontSize: 13.sp,

                    fontWeight: FontWeight.w600,

                  ),

                ),

        ),

      ),

    );

  }

}


