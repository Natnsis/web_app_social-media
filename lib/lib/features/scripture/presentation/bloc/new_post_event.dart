import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/scripture/domain/entities/new_post_type.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_state.dart';

sealed class NewPostEvent extends Equatable {
  const NewPostEvent();

  @override
  List<Object?> get props => [];
}

final class NewPostTypeChanged extends NewPostEvent {
  final NewPostType type;

  const NewPostTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

final class ScriptureNotifyCommunityToggled extends NewPostEvent {
  const ScriptureNotifyCommunityToggled();
}

final class NewPostEditingRestored extends NewPostEvent {
  final NewPostEditing editing;

  const NewPostEditingRestored(this.editing);

  @override
  List<Object?> get props => [editing];
}

final class NewPostMediaUpdated extends NewPostEvent {
  final UploadedMedia? media;

  const NewPostMediaUpdated(this.media);

  @override
  List<Object?> get props => [media];
}

final class NewPostMediaCaptionChanged extends NewPostEvent {
  final String caption;

  const NewPostMediaCaptionChanged(this.caption);

  @override
  List<Object?> get props => [caption];
}

final class AttachmentPostPublishRequested extends NewPostEvent {
  const AttachmentPostPublishRequested();
}

final class ScripturePostPublishRequested extends NewPostEvent {
  final String bibleReference;
  final String verseText;

  const ScripturePostPublishRequested({
    required this.bibleReference,
    required this.verseText,
  });

  @override
  List<Object?> get props => [bibleReference, verseText];
}
