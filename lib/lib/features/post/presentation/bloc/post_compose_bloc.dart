import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/event/data/mappers/create_event_mapper.dart';
import 'package:faithconnect/features/post/application/post_compose_service.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_event.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_state.dart';

class PostComposeBloc extends Bloc<PostComposeEvent, PostComposeState> {
  final PostComposeService _composeService;

  PostComposeBloc({required PostComposeService composeService})
      : _composeService = composeService,
        super(const PostComposeEditing(PostComposeDraft())) {
    on<PostComposeTypeChanged>(_onTypeChanged);
    on<PostComposeDraftUpdated>(_onDraftUpdated);
    on<PostComposeAllowCommentsToggled>(_onAllowCommentsToggled);
    on<PostComposeNotifyCommunityToggled>(_onNotifyCommunityToggled);
    on<PostComposePublishRequested>(_onPublishRequested);
    on<PostComposeEditingRestored>(_onEditingRestored);
  }

  PostComposeDraft? get _draft {
    final current = state;
    return switch (current) {
      PostComposeEditing(:final draft) => draft,
      PostComposeFailure(:final draft) => draft,
      _ => null,
    };
  }

  void _onEditingRestored(
    PostComposeEditingRestored event,
    Emitter<PostComposeState> emit,
  ) {
    emit(PostComposeEditing(event.draft));
  }

  void _onTypeChanged(
    PostComposeTypeChanged event,
    Emitter<PostComposeState> emit,
  ) {
    final draft = _draft;
    if (draft == null) return;
    emit(
      PostComposeEditing(
        draft.copyWith(
          selectedType: event.type,
          clearUploadedMedia: true,
        ),
      ),
    );
  }

  void _onDraftUpdated(
    PostComposeDraftUpdated event,
    Emitter<PostComposeState> emit,
  ) {
    emit(PostComposeEditing(event.draft));
  }

  void _onAllowCommentsToggled(
    PostComposeAllowCommentsToggled event,
    Emitter<PostComposeState> emit,
  ) {
    final draft = _draft;
    if (draft == null) return;
    emit(PostComposeEditing(draft.copyWith(allowComments: !draft.allowComments)));
  }

  void _onNotifyCommunityToggled(
    PostComposeNotifyCommunityToggled event,
    Emitter<PostComposeState> emit,
  ) {
    final draft = _draft;
    if (draft == null) return;
    emit(
      PostComposeEditing(
        draft.copyWith(notifyCommunity: !draft.notifyCommunity),
      ),
    );
  }

  Future<void> _onPublishRequested(
    PostComposePublishRequested event,
    Emitter<PostComposeState> emit,
  ) async {
    final draft = _draft;
    if (draft == null || draft.isPublishing) return;

    final validation = _validate(draft);
    if (validation != null) {
      emit(PostComposeFailure(validation, draft));
      return;
    }

    emit(PostComposeEditing(draft.copyWith(isPublishing: true)));

    final result = await _composeService.publish(draft);

    result.fold(
      (failure) => emit(
        PostComposeFailure(
          failure.message,
          draft.copyWith(isPublishing: false),
        ),
      ),
      (postId) => emit(
        PostComposePublishSuccess(
          postId: postId,
          message: _successMessage(draft.selectedType),
          composeType: draft.selectedType,
        ),
      ),
    );
  }

  String? _validate(PostComposeDraft draft) {
    switch (draft.selectedType) {
      case PostComposeType.post:
        final hasText = draft.textBody.trim().isNotEmpty;
        final hasMedia = draft.uploadedMedia != null;
        if (!hasText && !hasMedia) {
          return 'Please write a message or add an image or video.';
        }
      case PostComposeType.scripture:
        if (draft.bibleReference.trim().isEmpty ||
            draft.verseText.trim().isEmpty) {
          return 'Please enter a Bible reference and verse text.';
        }
      case PostComposeType.event:
        if (draft.eventTitle.trim().isEmpty) {
          return 'Please enter an event title.';
        }
        if (CreateEventMapper.parseDateLabel(draft.eventDateLabel) == null) {
          return 'Please select a valid event date.';
        }
        if (CreateEventMapper.parseTimeLabel(draft.eventTimeLabel) == null) {
          return 'Please select a valid event time.';
        }
      case PostComposeType.image:
        if (draft.uploadedMedia == null ||
            draft.uploadedMedia!.kind != MediaUploadKind.image) {
          return 'Please upload an image for this post.';
        }
      case PostComposeType.video:
        if (draft.uploadedMedia == null ||
            draft.uploadedMedia!.kind != MediaUploadKind.video) {
          return 'Please upload a video for this post.';
        }
      case PostComposeType.short:
        if (draft.uploadedMedia == null ||
            draft.uploadedMedia!.kind != MediaUploadKind.video) {
          return 'Please upload a short video.';
        }
      case PostComposeType.attachment:
        if (draft.uploadedMedia == null) {
          return 'Please attach an image or video.';
        }
    }
    return null;
  }

  String _successMessage(PostComposeType type) {
    return switch (type) {
      PostComposeType.post => 'Text post published',
      PostComposeType.image => 'Image post published',
      PostComposeType.video => 'Video post published',
      PostComposeType.short => 'Short published',
      PostComposeType.event => 'Event published',
      PostComposeType.scripture => 'Scripture post published',
      PostComposeType.attachment => 'Attachment published',
    };
  }
}
