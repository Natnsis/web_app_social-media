import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/scripture/domain/entities/new_post_type.dart';
import 'package:faithconnect/features/scripture/domain/entities/scripture_post.dart';

sealed class NewPostState extends Equatable {
  const NewPostState();

  @override
  List<Object?> get props => [];
}

final class NewPostEditing extends NewPostState {
  final NewPostType selectedType;
  final bool notifyCommunity;
  final bool isPublishing;
  final UploadedMedia? uploadedMedia;
  final String mediaCaption;

  const NewPostEditing({
    this.selectedType = NewPostType.scripture,
    this.notifyCommunity = true,
    this.isPublishing = false,
    this.uploadedMedia,
    this.mediaCaption = '',
  });

  NewPostEditing copyWith({
    NewPostType? selectedType,
    bool? notifyCommunity,
    bool? isPublishing,
    UploadedMedia? uploadedMedia,
    bool clearUploadedMedia = false,
    String? mediaCaption,
  }) {
    return NewPostEditing(
      selectedType: selectedType ?? this.selectedType,
      notifyCommunity: notifyCommunity ?? this.notifyCommunity,
      isPublishing: isPublishing ?? this.isPublishing,
      uploadedMedia: clearUploadedMedia
          ? null
          : (uploadedMedia ?? this.uploadedMedia),
      mediaCaption: mediaCaption ?? this.mediaCaption,
    );
  }

  @override
  List<Object?> get props => [
        selectedType,
        notifyCommunity,
        isPublishing,
        uploadedMedia,
        mediaCaption,
      ];
}

final class NewPostPublishSuccess extends NewPostState {
  final ScripturePost post;

  const NewPostPublishSuccess(this.post);

  @override
  List<Object?> get props => [post];
}

final class NewPostMediaPublishSuccess extends NewPostState {
  final String postId;

  const NewPostMediaPublishSuccess(this.postId);

  @override
  List<Object?> get props => [postId];
}

final class NewPostFailure extends NewPostState {
  final String message;
  final NewPostEditing previous;

  const NewPostFailure(this.message, this.previous);

  @override
  List<Object?> get props => [message, previous];
}
