import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/comment/application/comments_service.dart';
import 'package:faithconnect/features/post/application/post_service.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_detail_bloc.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_detail_event.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_detail_state.dart';
import 'package:faithconnect/features/post/presentation/widgets/post_comment_tile.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Comments sheet for feed [PostCard] — read and write without leaving the feed.
class PostCommentsBottomSheet extends StatefulWidget {
  final String postId;
  final ValueChanged<int>? onCommentCountChanged;

  const PostCommentsBottomSheet({
    super.key,
    required this.postId,
    this.onCommentCountChanged,
  });

  /// Opens the sheet; returns the latest comment count when dismissed.
  static Future<int?> show(
    BuildContext context, {
    required String postId,
    ValueChanged<int>? onCommentCountChanged,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => PostDetailBloc(
          postService: sl<PostService>(),
          commentsService: sl<CommentsService>(),
          churchService: sl<ChurchService>(),
          postId: postId,
        ),
        child: PostCommentsBottomSheet(
          postId: postId,
          onCommentCountChanged: onCommentCountChanged,
        ),
      ),
    );
  }

  @override
  State<PostCommentsBottomSheet> createState() =>
      _PostCommentsBottomSheetState();
}

class _PostCommentsBottomSheetState extends State<PostCommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  String? _replyParentId;
  String? _replyParentAuthor;
  String? _editCommentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _commentFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  int? _commentCountFromState(PostDetailState state) {
    if (state is PostDetailLoaded) {
      return state.detail.post.commentCount;
    }
    return null;
  }

  void _notifyCount(PostDetailState state) {
    final count = _commentCountFromState(state);
    final callback = widget.onCommentCountChanged;
    if (count == null || callback == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      callback(count);
    });
  }

  void _closeWithCount() {
    final count = _commentCountFromState(context.read<PostDetailBloc>().state);
    Navigator.of(context).pop(count);
  }

  void _startReply(PostComment comment) {
    setState(() {
      _replyParentId = comment.id;
      _replyParentAuthor = comment.authorName;
    });
    _commentController.clear();
    _commentFocusNode.requestFocus();
  }

  void _startEdit(PostComment comment) {
    setState(() {
      _editCommentId = comment.id;
      _replyParentId = null;
      _replyParentAuthor = null;
    });
    _commentController.text = comment.text;
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyParentId = null;
      _replyParentAuthor = null;
      _editCommentId = null;
    });
    _commentController.clear();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final bloc = context.read<PostDetailBloc>();
    if (_editCommentId != null) {
      bloc.add(
        PostDetailCommentEdited(
          commentId: _editCommentId!,
          text: text,
        ),
      );
    } else if (_replyParentId != null) {
      bloc.add(
        PostDetailReplySubmitted(
          parentCommentId: _replyParentId!,
          text: text,
        ),
      );
    } else {
      bloc.add(PostDetailCommentSubmitted(text));
    }

    _commentController.clear();
    _cancelReply();
    _commentFocusNode.requestFocus();
  }

  void _toggleCommentLike(PostComment comment) {
    context
        .read<PostDetailBloc>()
        .add(PostDetailCommentLikeToggled(comment.id));
  }

  void _loadReplies(PostComment comment) {
    context
        .read<PostDetailBloc>()
        .add(PostDetailRepliesRequested(comment.id));
  }

  Future<void> _confirmDeleteComment(PostComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<PostDetailBloc>().add(PostDetailCommentDeleted(comment.id));
  }

  void _openFullPost() {
    final count = _commentCountFromState(context.read<PostDetailBloc>().state);
    Navigator.of(context).pop(count);
    context.pushNamed(
      RoutesConstant.postDetail,
      pathParameters: {'id': widget.postId},
      queryParameters: const {'focus': 'comment'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final height = MediaQuery.sizeOf(context).height * 0.72;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _closeWithCount();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: colors.scaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: isDark
                ? null
                : Border(
                    top: BorderSide(color: colors.divider),
                    left: BorderSide(color: colors.divider),
                    right: BorderSide(color: colors.divider),
                  ),
          ),
          child: BlocConsumer<PostDetailBloc, PostDetailState>(
            listener: (context, state) {
              if (state is PostDetailFailure) {
                showWarning(context, state.message);
              } else if (state is PostDetailLoaded) {
                _notifyCount(state);
                final message = state.feedbackMessage;
                if (message != null && message.isNotEmpty) {
                  showWarning(context, message);
                  context
                      .read<PostDetailBloc>()
                      .add(const PostDetailFeedbackCleared());
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const SheetDragHandle(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 12.w, 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Comments',
                                style: GoogleFonts.inter(
                                  color: isDark
                                      ? colors.brandSky
                                      : colors.headerTitle,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (state is PostDetailLoaded)
                                Text(
                                  '${state.detail.post.commentCount} comments',
                                  style: GoogleFonts.inter(
                                    color: colors.mutedText,
                                    fontSize: 13.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _openFullPost,
                          child: Text(
                            'View post',
                            style: GoogleFonts.inter(
                              color: colors.brandBlue,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _closeWithCount,
                          icon: Container(
                            width: 36.r,
                            height: 36.r,
                            decoration: BoxDecoration(
                              color: colors.tagBackground,
                              shape: BoxShape.circle,
                              border: isDark
                                  ? null
                                  : Border.all(color: colors.divider),
                            ),
                            child: Icon(
                              Iconsax.close_circle,
                              color: colors.iconMuted,
                              size: 20.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildBody(context, state)),
                  if (state is PostDetailLoaded)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_replyParentAuthor != null || _editCommentId != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 0),
                            color: colors.tagBackground,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _editCommentId != null
                                        ? 'Editing comment'
                                        : 'Replying to $_replyParentAuthor',
                                    style: GoogleFonts.inter(
                                      color: colors.mutedText,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _cancelReply,
                                  icon: Icon(
                                    Iconsax.close_circle,
                                    size: 18.r,
                                    color: colors.iconMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        CommentComposerBar(
                          controller: _commentController,
                          focusNode: _commentFocusNode,
                          isSending: state.isSubmittingComment,
                          onSend: _submitComment,
                          onSubmitted: (_) => _submitComment(),
                          hint: _editCommentId != null
                              ? 'Edit comment...'
                              : _replyParentId == null
                                  ? 'Write a comment...'
                                  : 'Write a reply...',
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PostDetailState state) {
    final colors = context.faithColors;

    if (state is PostDetailLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.brandBlue),
      );
    }

    if (state is PostDetailFailure) {
      return Center(
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
      );
    }

    if (state is! PostDetailLoaded) {
      return const SizedBox.shrink();
    }

    final comments = state.detail.comments;

    if (comments.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Text(
            'No comments yet. Be the first to share your thoughts.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    final loadingReplyIds = state.loadingReplyParentIds;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return PostCommentTile(
          comment: comment,
          onReplyTap: _startReply,
          onLikeTap: _toggleCommentLike,
          onDeleteTap: _confirmDeleteComment,
          onEditTap: _startEdit,
          onLoadRepliesTap: _loadReplies,
          loadingReplyParentIds: loadingReplyIds,
        );
      },
    );
  }
}
