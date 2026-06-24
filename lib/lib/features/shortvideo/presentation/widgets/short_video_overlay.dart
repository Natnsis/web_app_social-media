import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_bloc.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_event.dart';
import 'package:faithconnect/features/shortvideo/presentation/widgets/reflections_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ShortVideoOverlay extends StatelessWidget {
  final ShortVideo video;
  final int index;
  final VoidCallback onLikeTap;
  final VoidCallback onFollowTap;

  const ShortVideoOverlay({
    super.key,
    required this.video,
    required this.index,
    required this.onLikeTap,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 8.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Shorts',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            bottom: 24.h,
            child: Column(
              children: [
                ShortActionRailButton(
                  icon: video.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  iconColor: video.isLiked ? Colors.redAccent : Colors.white,
                  label: video.isLiked ? formatCount(video.likeCount) : null,
                  showIconBackground: false,
                  onTap: onLikeTap,
                ),
                SizedBox(height: 18.h),
                ShortActionRailButton(
                  icon: Iconsax.message,
                  label: formatCount(video.reflectionCount),
                  onTap: () async {
                    final bloc = context.read<ShortsFeedBloc>();
                    final updatedCount = await ReflectionsBottomSheet.show(
                      context,
                      video.id,
                      onCountChanged: (count) {
                        bloc.add(ShortVideoReflectionCountChanged(
                          index: index,
                          count: count,
                        ));
                      },
                    );
                    if (updatedCount != null) {
                      bloc.add(ShortVideoReflectionCountChanged(
                        index: index,
                        count: updatedCount,
                      ));
                    }
                  },
                ),
                SizedBox(height: 18.h),
                ShortActionRailButton(
                  icon: Iconsax.send_2,
                  label: 'Share',
                  onTap: () => ContentShare.shareShort(
                    authorName: video.authorName,
                    caption: video.caption,
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: AppAvatar(
                      imageUrl: video.authorAvatarUrl,
                      size: 44,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16.w,
            right: 80.w,
            bottom: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: video.authorProfileId != null
                          ? () => context.pushNamed(
                                RoutesConstant.churchProfile,
                                pathParameters: {
                                  'id': video.authorProfileId!,
                                },
                              )
                          : null,
                      borderRadius: BorderRadius.circular(999),
                      child: AppAvatar(
                        imageUrl: video.authorAvatarUrl,
                        size: 40,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        video.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                    PrimaryButton.feedAction(
                      text: video.isFollowing ? 'Following' : 'Follow',
                      onPressed: onFollowTap,
                      backgroundColor: video.isFollowing
                          ? DarkTheme.feedTagBackground
                          : null,
                      fontSize: 12.sp,
                      width: 88.w,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  video.caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14.sp,
                    height: 1.4,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
                SizedBox(height: 10.h),
                GlassInfoPill(
                  leading: Icon(
                    Iconsax.musicnote,
                    color: Colors.white,
                    size: 16.r,
                  ),
                  text: video.audioLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
