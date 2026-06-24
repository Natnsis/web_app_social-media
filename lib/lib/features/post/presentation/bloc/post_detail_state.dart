import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/post/domain/entities/post_detail.dart';

sealed class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

final class PostDetailInitial extends PostDetailState {
  const PostDetailInitial();
}

final class PostDetailLoading extends PostDetailState {
  const PostDetailLoading();
}

final class PostDetailLoaded extends PostDetailState {
  final PostDetail detail;
  final bool isSubmittingComment;
  final Set<String> loadingReplyParentIds;
  final String? feedbackMessage;

  const PostDetailLoaded({
    required this.detail,
    this.isSubmittingComment = false,
    this.loadingReplyParentIds = const {},
    this.feedbackMessage,
  });

  PostDetailLoaded copyWith({
    PostDetail? detail,
    bool? isSubmittingComment,
    Set<String>? loadingReplyParentIds,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return PostDetailLoaded(
      detail: detail ?? this.detail,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
      loadingReplyParentIds:
          loadingReplyParentIds ?? this.loadingReplyParentIds,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  @override
  List<Object?> get props =>
      [detail, isSubmittingComment, loadingReplyParentIds, feedbackMessage];
}

final class PostDetailFailure extends PostDetailState {
  final String message;

  const PostDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
