import 'package:equatable/equatable.dart';

sealed class ReflectionsEvent extends Equatable {
  const ReflectionsEvent();

  @override
  List<Object?> get props => [];
}

final class ReflectionsRequested extends ReflectionsEvent {
  final String shortVideoId;

  const ReflectionsRequested(this.shortVideoId);

  @override
  List<Object?> get props => [shortVideoId];
}

final class ReflectionSubmitted extends ReflectionsEvent {
  final String text;

  const ReflectionSubmitted(this.text);

  @override
  List<Object?> get props => [text];
}

final class ReflectionRepliesRequested extends ReflectionsEvent {
  final String parentCommentId;

  const ReflectionRepliesRequested(this.parentCommentId);

  @override
  List<Object?> get props => [parentCommentId];
}

final class ReflectionReplySubmitted extends ReflectionsEvent {
  final String parentCommentId;
  final String text;
  final String? mediaPath;

  const ReflectionReplySubmitted({
    required this.parentCommentId,
    required this.text,
    this.mediaPath,
  });

  @override
  List<Object?> get props => [parentCommentId, text, mediaPath];
}

final class ReflectionLikeToggled extends ReflectionsEvent {
  final String commentId;

  const ReflectionLikeToggled(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

final class ReflectionDeleted extends ReflectionsEvent {
  final String commentId;

  const ReflectionDeleted(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

final class ReflectionEdited extends ReflectionsEvent {
  final String commentId;
  final String newText;

  const ReflectionEdited({
    required this.commentId,
    required this.newText,
  });

  @override
  List<Object?> get props => [commentId, newText];
}

final class ReflectionFeedbackCleared extends ReflectionsEvent {
  const ReflectionFeedbackCleared();
}
