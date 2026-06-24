import 'package:faithconnect/core/core.dart';

import 'package:faithconnect/features/post/presentation/bloc/post_detail_bloc.dart';

import 'package:faithconnect/features/post/presentation/bloc/post_detail_event.dart';

import 'package:faithconnect/features/post/presentation/bloc/post_detail_state.dart';

import 'package:faithconnect/features/post/presentation/widgets/post_comments_bottom_sheet.dart';

import 'package:faithconnect/features/post/domain/entities/post_detail.dart';

import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';

import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';

import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_header.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

class PostDetailPage extends StatefulWidget {

  final String postId;

  final bool autofocusComment;



  const PostDetailPage({

    super.key,

    required this.postId,

    this.autofocusComment = false,

  });



  @override

  State<PostDetailPage> createState() => _PostDetailPageState();

}



class _PostDetailPageState extends State<PostDetailPage> {

  bool _didAutoOpenComments = false;



  static const _emptyProfileStats = ProfileStats(

    subscriberCount: 0,

    subscriberGrowthPercent: 0,

    campaignCount: 0,

    campaignGrowthPercent: 0,

    monthlyGiftsTotal: 0,

    monthlyGiftsGrowthPercent: 0,

    livePeakViewers: 0,

    liveGrowthPercent: 0,

  );



  String? _buildSeenByLabel(String? source) {

    if (source == null) return null;

    final normalized = source.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (normalized.isEmpty) return null;



    final numberMatch = RegExp(

      r'(\d[\d,]*(?:\.\d+)?)\s*([kKmM]?)',

    ).firstMatch(normalized);



    if (numberMatch == null) {

      return normalized

          .replaceFirst(RegExp(r'^watched by', caseSensitive: false), 'Seen by')

          .replaceAll(RegExp(r'\s+others?\b', caseSensitive: false), '')

          .trim();

    }



    final numberText = (numberMatch.group(1) ?? '').replaceAll(',', '');

    final suffix = (numberMatch.group(2) ?? '').toLowerCase();

    final value = double.tryParse(numberText);

    if (value == null) return 'Seen by';



    final compactCount = switch (suffix) {

      'k' => '${_trimDecimal(value)}k',

      'm' => '${_trimDecimal(value)}m',

      _ when value >= 1000000 => '${_trimDecimal(value / 1000000)}m',

      _ when value >= 1000 => '${_trimDecimal(value / 1000)}k',

      _ => value.toInt().toString(),

    };



    return 'Seen by $compactCount';

  }



  String _trimDecimal(double value) {

    final oneDecimal = value.toStringAsFixed(1);

    return oneDecimal.endsWith('.0')

        ? oneDecimal.substring(0, oneDecimal.length - 2)

        : oneDecimal;

  }



  String _authorMeta(PostDetail detail) {

    final post = detail.post;

    if (detail.locationLabel != null) {

      return '${formatTimeAgo(post.createdAt)} • ${detail.locationLabel}';

    }

    return formatTimeAgo(post.createdAt);

  }



  OrganizationProfile _authorProfile(PostDetail detail) {

    final post = detail.post;

    return OrganizationProfile(

      id: post.authorProfileId ?? post.id,

      name: post.authorName,

      hubLabel: _authorMeta(detail),

      avatarUrl: post.authorAvatarUrl,

      owner: ProfileOwner(name: post.authorName, role: 'Author'),

      stats: _emptyProfileStats,

    );

  }



  Future<void> _openComments() async {

    await PostCommentsBottomSheet.show(

      context,

      postId: widget.postId,

    );

    if (!mounted) return;

    context.read<PostDetailBloc>().add(PostDetailRequested(widget.postId));

  }



  void _maybeAutoOpenComments() {

    if (!widget.autofocusComment || _didAutoOpenComments) return;

    _didAutoOpenComments = true;

    WidgetsBinding.instance.addPostFrameCallback((_) => _openComments());

  }



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;



    return Scaffold(

      backgroundColor: colors.scaffoldBackground,

      body: BlocConsumer<PostDetailBloc, PostDetailState>(

        listener: (context, state) {

          if (state is PostDetailFailure) {

            showWarning(context, state.message);

          } else if (state is PostDetailLoaded) {

            _maybeAutoOpenComments();

          }

        },

        builder: (context, state) {

          if (state is PostDetailLoading) {

            return Column(

              children: [

                ProfileHubAppBar(

                  title: 'Post',

                  onBack: () => context.pop(),

                ),

                Expanded(

                  child: Center(

                    child: CircularProgressIndicator(color: colors.brandBlue),

                  ),

                ),

              ],

            );

          }



          if (state is PostDetailFailure) {

            return Column(

              children: [

                ProfileHubAppBar(

                  title: 'Post',

                  onBack: () => context.pop(),

                ),

                Expanded(

                  child: Center(

                    child: Padding(

                      padding: AppSpacing.screenPadding,

                      child: Column(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Text(state.message, textAlign: TextAlign.center),

                          AppSpacing.v16,

                          PrimaryButton.feedAction(

                            text: 'Retry',

                            onPressed: () => context.read<PostDetailBloc>().add(

                                  PostDetailRequested(widget.postId),

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



          if (state is! PostDetailLoaded) {

            return const SizedBox.shrink();

          }



          final detail = state.detail;

          final post = detail.post;

          final authorProfile = _authorProfile(detail);

          _maybeAutoOpenComments();



          return CustomScrollView(

            physics: const BouncingScrollPhysics(

              parent: AlwaysScrollableScrollPhysics(),

            ),

            slivers: [

              SliverToBoxAdapter(

                child: ProfileHubHeader(

                  profile: authorProfile,

                  accountMenuTitle: 'Post',

                  onBack: () => context.pop(),

                  onProfileTap: post.authorProfileId != null

                      ? () => context.pushNamed(

                            RoutesConstant.churchProfile,

                            pathParameters: {'id': post.authorProfileId!},

                          )

                      : null,

                ),

              ),

              SliverToBoxAdapter(

                child: Padding(

                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [

                      Text(

                        post.content,

                        style: GoogleFonts.inter(

                          color: colors.primaryText.withValues(alpha: 0.92),

                          fontSize: 15.sp,

                          height: 1.5,

                        ),

                      ),

                      if (post.tags.isNotEmpty) ...[

                        SizedBox(height: 12.h),

                        Wrap(

                          spacing: 8.w,

                          runSpacing: 8.h,

                          children: post.tags

                              .map((tag) => AppTagChip(label: tag))

                              .toList(),

                        ),

                      ],

                      if (post.imageUrl != null) ...[

                        SizedBox(height: 16.h),

                        ClipRRect(

                          borderRadius: AppRadius.large,

                          child: AspectRatio(

                            aspectRatio: 4 / 5,

                            child: Image.network(

                              post.imageUrl!,

                              fit: BoxFit.cover,

                              errorBuilder: (context, error, stackTrace) =>

                                  Container(

                                color: colors.tagBackground,

                                child: Icon(

                                  Icons.broken_image_outlined,

                                  color: colors.mutedText,

                                ),

                              ),

                            ),

                          ),

                        ),

                      ],

                      SizedBox(height: 14.h),

                      PostInteractionBar(

                        likeCount: post.likeCount,

                        commentCount: post.commentCount,

                        isLiked: detail.isLiked,

                        isSaved: detail.isSaved,

                        trailingLabel: _buildSeenByLabel(post.watchedByLabel),

                        onLikeTap: () => context

                            .read<PostDetailBloc>()

                            .add(const PostDetailLikeToggled()),

                        onCommentTap: _openComments,

                        onSaveTap: () => context

                            .read<PostDetailBloc>()

                            .add(const PostDetailSaveToggled()),

                        onShareTap: () => ContentShare.sharePost(
                              authorName: post.authorName,
                              content: post.content,
                            ),

                      ),

                    ],

                  ),

                ),

              ),

            ],

          );

        },

      ),

    );

  }

}


