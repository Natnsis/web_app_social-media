import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/comment/application/comments_service.dart';
import 'package:faithconnect/features/comment/domain/utils/comment_tree_utils.dart';
import 'package:faithconnect/features/shortvideo/application/short_video_service.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/reflections_event.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/reflections_state.dart';

class ReflectionsBloc extends Bloc<ReflectionsEvent, ReflectionsState> {
  final ShortVideoService _shortVideoService;
  final CommentsService _commentsService;
  final String shortVideoId;

  ReflectionsBloc({
    required ShortVideoService shortVideoService,
    required CommentsService commentsService,
    required this.shortVideoId,
  })  : _shortVideoService = shortVideoService,
        _commentsService = commentsService,
        super(const ReflectionsLoading()) {
    on<ReflectionsRequested>(_onRequested);
    on<ReflectionSubmitted>(_onSubmitted);
    on<ReflectionRepliesRequested>(_onRepliesRequested);
    on<ReflectionReplySubmitted>(_onReplySubmitted);
    on<ReflectionLikeToggled>(_onLikeToggled);
    on<ReflectionEdited>(_onEdited);
    on<ReflectionDeleted>(_onDeleted);
    on<ReflectionFeedbackCleared>(_onFeedbackCleared);

    add(ReflectionsRequested(shortVideoId));
  }

  Future<void> _onEdited(
    ReflectionEdited event,
    Emitter<ReflectionsState> emit,
  ) async {
    final current = state;
    if (current is! ReflectionsLoaded) return;

    // Optimistically show a submitting state
    emit(current.copyWith(isSubmitting: true, clearFeedback: true));

    final result = await _commentsService.updateReflection(
      commentId: event.commentId,
      body: event.newText,
    );

    // Re-read state after async gap to avoid stale reference
    final latest = state;
    if (latest is! ReflectionsLoaded) return;

    result.fold(
      (failure) {
        emit(
          latest.copyWith(
            isSubmitting: false,
            feedbackMessage: failure.message,
          ),
        );
      },
      (updatedReflection) {
        emit(
          latest.copyWith(
            isSubmitting: false,
            feed: latest.feed.copyWith(
              reflections: _updateReflectionInList(
                latest.feed.reflections,
                updatedReflection,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Reflection> _updateReflectionInList(
    List<Reflection> list,
    Reflection updatedReflection,
  ) {
    return list.map((r) {
      if (r.id == updatedReflection.id) {
        return r.copyWith(
          text: updatedReflection.text,
          isOwnedByMe: updatedReflection.isOwnedByMe || r.isOwnedByMe,
        );
      }
      if (r.replies.isNotEmpty) {
        return r.copyWith(
          replies: _updateReflectionInList(r.replies, updatedReflection),
        );
      }
      return r;
    }).toList();
  }

  Future<void> _onRequested(
    ReflectionsRequested event,
    Emitter<ReflectionsState> emit,
  ) async {
    emit(const ReflectionsLoading());
    final result = await _shortVideoService.getReflections(event.shortVideoId);
    result.fold(
      (failure) => emit(ReflectionsFailure(failure.message)),
      (feed) => emit(ReflectionsLoaded(feed: feed)),
    );
  }

  Future<void> _onSubmitted(
    ReflectionSubmitted event,
    Emitter<ReflectionsState> emit,
  ) async {
    final current = state;
    if (current is! ReflectionsLoaded) return;

    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(current.copyWith(isSubmitting: true));

    final result = await _shortVideoService.addReflection(
      shortVideoId: shortVideoId,
      text: text,
    );

    // Re-read state after async gap to avoid stale reference
    final latest = state;
    if (latest is! ReflectionsLoaded) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isSubmitting: false,
          feedbackMessage: failure.message,
        ),
      ),
      (reflection) {
        emit(
          latest.copyWith(
            isSubmitting: false,
            feed: latest.feed.copyWith(
              totalReflecting: latest.feed.totalReflecting + 1,
              reflections: [reflection.copyWith(isOwnedByMe: true), ...latest.feed.reflections],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onRepliesRequested(
    ReflectionRepliesRequested event,
    Emitter<ReflectionsState> emit,
  ) async {
    final current = state;
    if (current is! ReflectionsLoaded) return;
    if (current.loadingReplyParentIds.contains(event.parentCommentId)) return;

    final loading = {...current.loadingReplyParentIds, event.parentCommentId};
    emit(current.copyWith(loadingReplyParentIds: loading, clearFeedback: true));

    final result = await _commentsService.fetchReflectionReplies(
      event.parentCommentId,
    );

    final latest = state;
    if (latest is! ReflectionsLoaded) return;

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
            feed: latest.feed.copyWith(
              reflections: CommentTreeUtils.attachReflectionReplies(
                latest.feed.reflections,
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
    ReflectionReplySubmitted event,
    Emitter<ReflectionsState> emit,
  ) async {
    final started = state;
    if (started is! ReflectionsLoaded) return;

    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(started.copyWith(isSubmitting: true, clearFeedback: true));

    // API spec: ALL replies at every depth use the same endpoint:
    // POST /v1/shorts/{id}/comments  with  parentId = <comment or reply UUID>
    // The `parentIsTopLevel` distinction is no longer needed for posting.
    final result = await _shortVideoService.addReflection(
      shortVideoId: shortVideoId,
      text: text,
      parentCommentId: event.parentCommentId, // sent as `parentId` in form data
    );

    final latest = state;
    if (latest is! ReflectionsLoaded) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isSubmitting: false,
          feedbackMessage: failure.message,
        ),
      ),
      (reply) => emit(
        latest.copyWith(
          isSubmitting: false,
          feed: latest.feed.copyWith(
            totalReflecting: latest.feed.totalReflecting + 1,
            reflections: CommentTreeUtils.appendReflectionReply(
              latest.feed.reflections,
              event.parentCommentId,
              reply.copyWith(isOwnedByMe: true),
            ),
          ),
        ),
      ),
    );
  }


  void _onFeedbackCleared(
    ReflectionFeedbackCleared event,
    Emitter<ReflectionsState> emit,
  ) {
    final current = state;
    if (current is! ReflectionsLoaded) return;
    emit(current.copyWith(clearFeedback: true));
  }

  Future<void> _onLikeToggled(
    ReflectionLikeToggled event,
    Emitter<ReflectionsState> emit,
  ) async {
    final current = state;
    if (current is! ReflectionsLoaded) return;

    final reflection = CommentTreeUtils.findReflection(
      current.feed.reflections,
      event.commentId,
    );
    if (reflection == null) return;

    final liked = !reflection.isLiked;
    final delta = liked ? 1 : -1;
    final previousFeed = current.feed;

    emit(
      ReflectionsLoaded(
        feed: previousFeed.copyWith(
          reflections: CommentTreeUtils.updateReflection(
            previousFeed.reflections,
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
      // Rollback: restore the pre-optimistic state on API failure
      (_) => emit(
        ReflectionsLoaded(
          feed: previousFeed,
          loadingReplyParentIds: const {},
        ),
      ),
      (likeState) {
        // Confirm with server-authoritative counts
        final currentFeed = (state is ReflectionsLoaded)
            ? (state as ReflectionsLoaded).feed
            : previousFeed;
        emit(
          ReflectionsLoaded(
            feed: currentFeed.copyWith(
              reflections: CommentTreeUtils.updateReflection(
                currentFeed.reflections,
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

  Future<void> _onDeleted(
    ReflectionDeleted event,
    Emitter<ReflectionsState> emit,
  ) async {
    final current = state;
    if (current is! ReflectionsLoaded) return;

    final previousFeed = current.feed;
    final isTopLevel = previousFeed.reflections.any((r) => r.id == event.commentId);

    final result = isTopLevel
        ? await _shortVideoService.deleteReflection(
            shortVideoId: shortVideoId,
            commentId: event.commentId,
          )
        : await _commentsService.deleteComment(event.commentId);

    result.fold(
      (failure) {
        emit(
          ReflectionsLoaded(
            feed: previousFeed,
            feedbackMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(
          ReflectionsLoaded(
            feed: previousFeed.copyWith(
              totalReflecting: (previousFeed.totalReflecting - 1).clamp(0, 999999999),
              reflections: CommentTreeUtils.removeReflection(
                previousFeed.reflections,
                event.commentId,
              ),
            ),
          ),
        );
      },
    );
  }
}
