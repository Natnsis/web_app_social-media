import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';

sealed class PostComposeState extends Equatable {
  const PostComposeState();

  @override
  List<Object?> get props => [];
}

class PostComposeEditing extends PostComposeState {
  final PostComposeDraft draft;

  const PostComposeEditing(this.draft);

  @override
  List<Object?> get props => [draft];
}

class PostComposeFailure extends PostComposeState {
  final String message;
  final PostComposeDraft draft;

  const PostComposeFailure(this.message, this.draft);

  @override
  List<Object?> get props => [message, draft];
}

class PostComposePublishSuccess extends PostComposeState {
  final String postId;
  final String message;
  final PostComposeType composeType;

  const PostComposePublishSuccess({
    required this.postId,
    required this.message,
    required this.composeType,
  });

  @override
  List<Object?> get props => [postId, message, composeType];
}
