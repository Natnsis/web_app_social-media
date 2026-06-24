import 'package:equatable/equatable.dart';

sealed class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

final class PostDetailRequested extends PostDetailEvent {
  final String postId;

  const PostDetailRequested(this.postId);

  @override
  List<Object?> get props => [postId];
}

final class PostDetailLikeToggled extends PostDetailEvent {
  const PostDetailLikeToggled();
}

final class PostDetailSaveToggled extends PostDetailEvent {
  const PostDetailSaveToggled();
}

final class PostDetailFollowToggled extends PostDetailEvent {
  const PostDetailFollowToggled();
}

final class PostDetailCommentSubmitted extends PostDetailEvent {
  final String text;

  const PostDetailCommentSubmitted(this.text);

  @override
  List<Object?> get props => [text];
}

final class PostDetailRepliesRequested extends PostDetailEvent {
  final String parentCommentId;

  const PostDetailRepliesRequested(this.parentCommentId);

  @override
  List<Object?> get props => [parentCommentId];
}

final class PostDetailReplySubmitted extends PostDetailEvent {
  final String parentCommentId;
  final String text;
  final String? mediaPath;

  const PostDetailReplySubmitted({
    required this.parentCommentId,
    required this.text,
    this.mediaPath,
  });

  @override
  List<Object?> get props => [parentCommentId, text, mediaPath];
}

final class PostDetailCommentLikeToggled extends PostDetailEvent {
  final String commentId;

  const PostDetailCommentLikeToggled(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

final class PostDetailCommentDeleted extends PostDetailEvent {
  final String commentId;

  const PostDetailCommentDeleted(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

final class PostDetailCommentEdited extends PostDetailEvent {
  final String commentId;
  final String text;

  const PostDetailCommentEdited({
    required this.commentId,
    required this.text,
  });

  @override
  List<Object?> get props => [commentId, text];
}

final class PostDetailFeedbackCleared extends PostDetailEvent {
  const PostDetailFeedbackCleared();
}
