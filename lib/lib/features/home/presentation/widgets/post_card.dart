import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/post/application/post_service.dart';
import 'package:faithconnect/features/post/presentation/widgets/post_comments_bottom_sheet.dart';
import 'package:faithconnect/core/constants/save_bookmark_icons.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_content_manage_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool showManageActions;
  final VoidCallback? onManageTap;

  const PostCard({
    super.key,
    required this.post,
    this.showManageActions = false,
    this.onManageTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isDeleted = false;
  String? _contentOverride;

  Future<void> _handleInternalManage() async {
    final action = await showProfileContentManageSheet(
      context,
      kind: ProfileContentKind.post,
    );
    if (!mounted || action == null) return;

    if (action == ProfileContentManageAction.edit) {
      final updated = await context.pushNamed<Map<String, dynamic>>(
        RoutesConstant.editPost,
        pathParameters: {'id': widget.post.id},
        extra: widget.post,
      );
      if (!mounted || updated == null) return;

      final content = updated['content'] as String;
      final newMedia = updated['newMedia'] as UploadedMedia?;
      final removeExistingMedia =
          updated['removeExistingMedia'] as bool? ?? false;

      final result = await sl<PostService>().updatePost(
        postId: widget.post.id,
        content: content,
        newMedia: newMedia,
        removeExistingMedia: removeExistingMedia,
      );
      if (!mounted) return;

      result.fold(
        (failure) => showError(context, failure.message),
        (_) => setState(() => _contentOverride = content),
      );
    } else if (action == ProfileContentManageAction.delete) {
      final confirmed = await confirmProfileContentDelete(
        context,
        kind: ProfileContentKind.post,
      );
      if (!mounted || !confirmed) return;

      final result = await sl<PostService>().deletePost(widget.post.id);
      if (!mounted) return;

      result.fold(
        (failure) => showError(context, failure.message),
        (_) => setState(() => _isDeleted = true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleted) return const SizedBox.shrink();

    final post = widget.post;
    final theme = Theme.of(context);
    final colors = context.faithColors;

    final isDark = context.isDarkMode;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.large,
        border: isDark ? null : Border.all(color: colors.divider),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pushNamed(
                RoutesConstant.postDetail,
                pathParameters: {'id': post.id},
              ),
              onDoubleTap: widget.showManageActions
                  ? (widget.onManageTap ?? _handleInternalManage)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: post.authorProfileId != null
                              ? () => context.pushNamed(
                                  RoutesConstant.churchProfile,
                                  pathParameters: {'id': post.authorProfileId!},
                                )
                              : null,
                          borderRadius: BorderRadius.circular(999),
                          child: _AuthorAvatar(url: post.authorAvatarUrl),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: InkWell(
                            onTap: post.authorProfileId != null
                                ? () => context.pushNamed(
                                    RoutesConstant.churchProfile,
                                    pathParameters: {
                                      'id': post.authorProfileId!,
                                    },
                                  )
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colors.primaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  post.timeAgoLabel ??
                                      formatTimeAgo(post.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.showManageActions)
                          IconButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: colors.mutedText,
                              size: 22.r,
                            ),
                            tooltip: 'Manage post',
                            onPressed:
                                widget.onManageTap ?? _handleInternalManage,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
                    child: Text(
                      _contentOverride ?? post.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.primaryText.withValues(alpha: 0.92),
                        height: 1.45,
                      ),
                    ),
                  ),

                  if (post.imageUrl != null &&
                      post.mediaType != PostMediaType.text) ...[
                    SizedBox(height: 12.h),
                    _PostMedia(post: post),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: SizedBox(
              width: double.infinity,
              child: _PostActions(
                key: ValueKey('post-actions-${post.id}'),
                post: post,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _AuthorAvatar extends StatelessWidget {
  final String? url;

  const _AuthorAvatar({this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return CircleAvatar(
      radius: 18.r,
      backgroundColor: colors.tagBackground,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null
          ? Icon(Icons.church, size: 18.r, color: colors.mutedText)
          : null,
    );
  }
}

class _PostMedia extends StatelessWidget {
  final Post post;

  const _PostMedia({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isVideo = post.mediaType == PostMediaType.video;

    return AspectRatio(
      aspectRatio: isVideo ? 16 / 10 : 4 / 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: colors.tagBackground,
              child: Icon(Icons.broken_image_outlined, color: colors.mutedText),
            ),
          ),
          if (isVideo)
            Center(
              child: Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: colors.brandBlue.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 36.r,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostActions extends StatefulWidget {
  final Post post;

  const _PostActions({super.key, required this.post});

  @override
  State<_PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<_PostActions> {
  late final PostService _postService;
  bool _isLiked = false;
  bool _isSaved = false;
  int _likeCount = 0;
  bool _isLiking = false;
  bool _isSaving = false;
  int? _commentCountOverride;

  int get _displayCommentCount =>
      _commentCountOverride ?? widget.post.commentCount;

  void _syncFromPost(Post post) {
    _isLiked = post.isLiked;
    _isSaved = post.isSaved;
    _likeCount = post.likeCount;
    _commentCountOverride = null;
  }

  @override
  void initState() {
    super.initState();
    _postService = sl<PostService>();
    _syncFromPost(widget.post);
  }

  @override
  void didUpdateWidget(covariant _PostActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _syncFromPost(widget.post);
    } else {
      if (oldWidget.post.commentCount != widget.post.commentCount) {
        _commentCountOverride = null;
      }
      // Only sync like state from parent when we are NOT in the middle of
      // an in-flight request — otherwise the optimistic UI is clobbered.
      if (!_isLiking &&
          (oldWidget.post.likeCount != widget.post.likeCount ||
              oldWidget.post.isLiked != widget.post.isLiked)) {
        _isLiked = widget.post.isLiked;
        _likeCount = widget.post.likeCount;
      }
    }
  }

  void _applyCommentCount(int count) {
    if (!mounted) return;
    setState(() => _commentCountOverride = count);
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;

    final postId = widget.post.id;
    final wasLiked = _isLiked;
    final previousCount = _likeCount;
    final willLike = !wasLiked;

    setState(() {
      _isLiking = true;
      _isLiked = willLike;
      _likeCount = (previousCount + (willLike ? 1 : -1)).clamp(0, 999999999);
    });

    final result = willLike
        ? await _postService.likePost(postId)
        : await _postService.unlikePost(postId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLiking = false;
          // Rollback to pre-tap state on failure
          _isLiked = wasLiked;
          _likeCount = previousCount;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showWarning(context, failure.message);
        });
      },
      (likeState) {
        setState(() {
          _isLiking = false;
          _isLiked = likeState.isLiked;
          // -1 means the server didn't return a count (e.g. 204 No Content)
          // so we keep our own optimistic count.
          if (likeState.likeCount >= 0) {
            _likeCount = likeState.likeCount;
          }
        });
      },
    );
  }

  Future<void> _toggleSave() async {
    if (_isSaving) return;

    final postId = widget.post.id;
    final wasSaved = _isSaved;
    final willSave = !wasSaved;

    setState(() {
      _isSaving = true;
      _isSaved = willSave;
    });

    final result = willSave
        ? await _postService.savePost(postId)
        : await _postService.unsavePost(postId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSaving = false;
          _isSaved = wasSaved;
        });
        showWarning(context, failure.message);
      },
      (_) {
        setState(() {
          _isSaving = false;
        });
      },
    );
  }

  Future<void> _sharePost() async {
    final post = widget.post;
    await ContentShare.sharePost(
      authorName: post.authorName,
      content: post.content,
    );
  }

  Future<void> _openComments() async {
    final updated = await PostCommentsBottomSheet.show(
      context,
      postId: widget.post.id,
      onCommentCountChanged: _applyCommentCount,
    );
    if (!mounted || updated == null) return;
    _applyCommentCount(updated);
  }

  String? _buildSeenByLabel(String? source) {
    if (source == null) return null;
    final normalized = source.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return null;

    final numberMatch = RegExp(
      r'(\d[\d,]*(?:\.\d+)?)\s*([kKmM]?)',
    ).firstMatch(normalized);

    if (numberMatch == null) {
      return normalized
          .replaceFirst(RegExp(r'^watched by', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+others?\b', caseSensitive: false), '')
          .trim();
    }

    final numberText = (numberMatch.group(1) ?? '').replaceAll(',', '');
    final suffix = (numberMatch.group(2) ?? '').toLowerCase();
    final value = double.tryParse(numberText);
    if (value == null) return null;

    final compactCount = switch (suffix) {
      'k' => '${_trimDecimal(value)}k',
      'm' => '${_trimDecimal(value)}m',
      _ when value >= 1000000 => '${_trimDecimal(value / 1000000)}m',
      _ when value >= 1000 => '${_trimDecimal(value / 1000)}k',
      _ => value.toInt().toString(),
    };

    return compactCount;
  }

  String _trimDecimal(double value) {
    final oneDecimal = value.toStringAsFixed(1);
    return oneDecimal.endsWith('.0')
        ? oneDecimal.substring(0, oneDecimal.length - 2)
        : oneDecimal;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final muted = colors.mutedText;
    final active = colors.brandBlue;
    final viewCountLabel = _buildSeenByLabel(widget.post.watchedByLabel);
    final likeColor = _isLiked ? Colors.redAccent : muted;
    final likeIcon = _isLiked
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;

    return Row(
      children: [
        _InlineMetricAction(
          icon: likeIcon,
          label: _isLiked ? formatCount(_likeCount) : null,
          color: likeColor,
          onTap: _isLiking ? null : _toggleLike,
        ),
        SizedBox(width: 14.w),
        _InlineMetricAction(
          icon: Icons.chat_bubble_outline_rounded,
          label: formatCount(_displayCommentCount),
          color: muted,
          onTap: _openComments,
        ),
        const Spacer(),
        if (viewCountLabel != null && viewCountLabel.isNotEmpty) ...[
          _InlineMetricAction(
            icon: Icons.remove_red_eye_outlined,
            label: viewCountLabel,
            color: muted,
          ),
          SizedBox(width: 8.w),
        ],
        _IconActionButton(
          icon: saveBookmarkIcon(isSaved: _isSaved),
          color: _isSaved ? active : muted,
          tooltip: _isSaved ? 'Saved for later' : 'Save for later',
          onPressed: _toggleSave,
        ),
       
      ],
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22.r, color: color),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: tooltip,
    );
  }
}

class _InlineMetricAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback? onTap;

  const _InlineMetricAction({
    required this.icon,
    this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22.r, color: color),
              if (label != null) ...[
                SizedBox(width: 4.w),
                Text(
                  label!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
