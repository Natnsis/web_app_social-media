import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/comment/application/comments_service.dart';
import 'package:faithconnect/features/comment/domain/utils/comment_tree_utils.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/post/application/post_service.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_detail_event.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final PostService _postService;
  final CommentsService _commentsService;
  final ChurchService _churchService;
  final String postId;

  PostDetailBloc({
    required PostService postService,
    required CommentsService commentsService,
    required ChurchService churchService,
    required this.postId,
  })  : _postService = postService,
        _commentsService = commentsService,
        _churchService = churchService,
        super(const PostDetailLoading()) {
    on<PostDetailRequested>(_onRequested);
    on<PostDetailLikeToggled>(_onLikeToggled);
    on<PostDetailSaveToggled>(_onSaveToggled);
    on<PostDetailFollowToggled>(_onFollowToggled);
    on<PostDetailCommentSubmitted>(_onCommentSubmitted);
    on<PostDetailRepliesRequested>(_onRepliesRequested);
    on<PostDetailReplySubmitted>(_onReplySubmitted);
    on<PostDetailCommentLikeToggled>(_onCommentLikeToggled);
    on<PostDetailCommentDeleted>(_onCommentDeleted);
    on<PostDetailCommentEdited>(_onCommentEdited);
    on<PostDetailFeedbackCleared>(_onFeedbackCleared);

    add(PostDetailRequested(postId));
  }

  Future<void> _onRequested(
    PostDetailRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(const PostDetailLoading());
    final result = await _postService.getPostDetail(event.postId);
    result.fold(
      (failure) => emit(PostDetailFailure(failure.message)),
      (detail) => emit(PostDetailLoaded(detail: detail)),
    );
  }

  Future<void> _onLikeToggled(
    PostDetailLikeToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;

    final detail = current.detail;
    final post = detail.post;
    final wasLiked = detail.isLiked;
    final previousCount = post.likeCount;
    final willLike = !wasLiked;
    final optimisticCount =
        (previousCount + (willLike ? 1 : -1)).clamp(0, 999999999);

    emit(
      current.copyWith(
        detail: detail.copyWith(
          isLiked: willLike,
          post: post.copyWith(
            isLiked: willLike,
            likeCount: optimisticCount,
          ),
        ),
      ),
    );

    final result = willLike
        ? await _postService.likePost(postId)
        : await _postService.unlikePost(postId);

    final latest = state;
    if (latest is! PostDetailLoaded) return;

    result.fold(
      (failure) {
        emit(
          latest.copyWith(
            feedbackMessage: failure.message,
            detail: latest.detail.copyWith(
              isLiked: wasLiked,
              post: latest.detail.post.copyWith(
                isLiked: wasLiked,
                likeCount: previousCount,
              ),
            ),
          ),
        );
      },
      (likeState) {
        emit(
          latest.copyWith(
            detail: latest.detail.copyWith(
              isLiked: likeState.isLiked,
              post: latest.detail.post.copyWith(
                isLiked: likeState.isLiked,
                likeCount: likeState.likeCount,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSaveToggled(
    PostDetailSaveToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;

    final detail = current.detail;
    final wasSaved = detail.isSaved;
    final willSave = !wasSaved;

    emit(
      current.copyWith(
        detail: detail.copyWith(isSaved: willSave),
      ),
    );

    final result = willSave
        ? await _postService.savePost(postId)
        : await _postService.unsavePost(postId);

    final latest = state;
    if (latest is! PostDetailLoaded) return;

    result.fold(
      (failure) {
        emit(
          latest.copyWith(
            feedbackMessage: failure.message,
            detail: latest.detail.copyWith(isSaved: wasSaved),
          ),
        );
      },
      (_) {},
    );
  }


  Future<void> _onFollowToggled(
    PostDetailFollowToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;

    final churchId = current.detail.post.authorProfileId;
    if (churchId == null || churchId.isEmpty) return;

    final follow = !current.detail.isFollowingAuthor;
    final previousDetail = current.detail;

    emit(
      current.copyWith(
        detail: previousDetail.copyWith(isFollowingAuthor: follow),
      ),
    );

    final result = follow
        ? await _churchService.toggleFollowChurch(
            churchId: churchId,
            follow: true,
          )
        : await _churchService.unfollowChurch(churchId: churchId);

    result.fold(
      (_) => emit(current.copyWith(detail: previousDetail)),
      (_) {},
    );
  }

  Future<void> _onCommentSubmitted(
    PostDetailCommentSubmitted event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;

    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(current.copyWith(isSubmittingComment: true));

    final result = await _postService.addComment(postId: postId, text: text);

    result.fold(
      (failure) => emit(
        current.copyWith(
          isSubmittingComment: false,
          feedbackMessage: failure.message,
        ),
      ),
      (comment) {
        final detail = current.detail;
        final post = detail.post;
        emit(
          current.copyWith(
            isSubmittingComment: false,
            detail: detail.copyWith(
              comments: [comment, ...detail.comments],
              post: Post(
                id: post.id,
                authorName: post.authorName,
                authorProfileId: post.authorProfileId,
                authorAvatarUrl: post.authorAvatarUrl,
                content: post.content,
                imageUrl: post.imageUrl,
                mediaType: post.mediaType,
                tags: post.tags,
                likeCount: post.likeCount,
                commentCount: post.commentCount + 1,
                watchedByLabel: post.watchedByLabel,
                createdAt: post.createdAt,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onRepliesRequested(
    PostDetailRepliesRequested event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;
    if (current.loadingReplyParentIds.contains(event.parentCommentId)) return;

    final loading = {...current.loadingReplyParentIds, event.parentCommentId};
    emit(current.copyWith(loadingReplyParentIds: loading, clearFeedback: true));

    final result = await _commentsService.fetchPostCommentReplies(
      event.parentCommentId,
    );

    final latest = state;
    if (latest is! PostDetailLoaded) return;

    final doneLoading = {...latest.loadingReplyParentIds}
      ..remove(event.parentCommentId);

    result.fold(
      (failure) => emit(
        latest.copyWith(
          loadingReplyParentIds: doneLoading,
          feedbackMessage: failure.message,
        ),
      ),
      (replies) {
        emit(
          latest.copyWith(
            loadingReplyParentIds: doneLoading,
            detail: latest.detail.copyWith(
              comments: CommentTreeUtils.attachPostCommentReplies(
                latest.detail.comments,
                event.parentCommentId,
                replies,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onReplySubmitted(
    PostDetailReplySubmitted event,
    Emitter<PostDetailState> emit,
  ) async {
    final started = state;
    if (started is! PostDetailLoaded) return;

    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(started.copyWith(isSubmittingComment: true, clearFeedback: true));

    final result = await _commentsService.replyToPostComment(
      parentCommentId: event.parentCommentId,
      body: text,
      mediaPath: event.mediaPath,
    );

    final latest = state;
    if (latest is! PostDetailLoaded) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isSubmittingComment: false,
          feedbackMessage: failure.message,
        ),
      ),
      (reply) => emit(
        latest.copyWith(
          isSubmittingComment: false,
          detail: latest.detail.copyWith(
            comments: CommentTreeUtils.appendPostCommentReply(
              latest.detail.comments,
              event.parentCommentId,
              reply,
            ),
          ),
        ),
      ),
    );
  }

  void _onFeedbackCleared(
    PostDetailFeedbackCleared event,
    Emitter<PostDetailState> emit,
  ) {
    final current = state;
    if (current is! PostDetailLoaded) return;
    emit(current.copyWith(clearFeedback: true));
  }

  Future<void> _onCommentEdited(
    PostDetailCommentEdited event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;

    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(current.copyWith(isSubmittingComment: true, clearFeedback: true));

    final result = await _commentsService.updatePostComment(
      commentId: event.commentId,
      body: text,
    );

    final latest = state;
    if (latest is! PostDetailLoaded) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isSubmittingComment: false,
          feedbackMessage: failure.message,
        ),
      ),
      (updatedComment) {
        emit(
          latest.copyWith(
            isSubmittingComment: false,
            detail: latest.detail.copyWith(
              comments: CommentTreeUtils.updatePostComment(
                latest.detail.comments,
                updatedComment.id,
                (old) => updatedComment,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onCommentLikeToggled(
    PostDetailCommentLikeToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;

    final comment = CommentTreeUtils.findPostComment(
      current.detail.comments,
      event.commentId,
    );
    if (comment == null) return;

    final liked = !comment.isLiked;
    final delta = liked ? 1 : -1;
    final previousDetail = current.detail;

    emit(
      PostDetailLoaded(
        detail: previousDetail.copyWith(
          comments: CommentTreeUtils.updatePostComment(
            previousDetail.comments,
            event.commentId,
            (item) => item.copyWith(
              isLiked: liked,
              likeCount: (item.likeCount + delta).clamp(0, 999999999),
            ),
          ),
        ),
      ),
    );

    final result = liked
        ? await _commentsService.likeComment(event.commentId)
        : await _commentsService.unlikeComment(event.commentId);

    result.fold(
      (_) => emit(PostDetailLoaded(detail: previousDetail)),
      (likeState) {
        emit(
          PostDetailLoaded(
            detail: previousDetail.copyWith(
              comments: CommentTreeUtils.updatePostComment(
                previousDetail.comments,
                event.commentId,
                (item) => item.copyWith(
                  isLiked: likeState.isLiked,
                  likeCount: likeState.likeCount,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onCommentDeleted(
    PostDetailCommentDeleted event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;

    final previousDetail = current.detail;
    final result = await _commentsService.deleteComment(event.commentId);

    result.fold(
      (_) {},
      (_) {
        final post = previousDetail.post;
        emit(
          PostDetailLoaded(
            detail: previousDetail.copyWith(
              comments: CommentTreeUtils.removePostComment(
                previousDetail.comments,
                event.commentId,
              ),
              post: Post(
                id: post.id,
                authorName: post.authorName,
                authorProfileId: post.authorProfileId,
                authorAvatarUrl: post.authorAvatarUrl,
                content: post.content,
                imageUrl: post.imageUrl,
                mediaType: post.mediaType,
                tags: post.tags,
                likeCount: post.likeCount,
                commentCount: (post.commentCount - 1).clamp(0, 999999999),
                watchedByLabel: post.watchedByLabel,
                createdAt: post.createdAt,
              ),
            ),
          ),
        );
      },
    );
  }
}
