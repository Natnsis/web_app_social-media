import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';

sealed class PostComposeEvent extends Equatable {
  const PostComposeEvent();

  @override
  List<Object?> get props => [];
}

class PostComposeTypeChanged extends PostComposeEvent {
  final PostComposeType type;

  const PostComposeTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class PostComposeDraftUpdated extends PostComposeEvent {
  final PostComposeDraft draft;

  const PostComposeDraftUpdated(this.draft);

  @override
  List<Object?> get props => [draft];
}

class PostComposeAllowCommentsToggled extends PostComposeEvent {
  const PostComposeAllowCommentsToggled();
}

class PostComposeNotifyCommunityToggled extends PostComposeEvent {
  const PostComposeNotifyCommunityToggled();
}

class PostComposePublishRequested extends PostComposeEvent {
  const PostComposePublishRequested();
}

class PostComposeEditingRestored extends PostComposeEvent {
  final PostComposeDraft draft;

  const PostComposeEditingRestored(this.draft);

  @override
  List<Object?> get props => [draft];
}
