import 'package:faithconnect/features/post/application/post_compose_service.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/scripture/application/scripture_service.dart';
import 'package:faithconnect/features/scripture/domain/entities/new_post_type.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_event.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_state.dart';

class NewPostBloc extends Bloc<NewPostEvent, NewPostState> {
  final ScriptureService _scriptureService;
  final PostComposeService _postComposeService;

  NewPostBloc({
    required ScriptureService scriptureService,
    required PostComposeService postComposeService,
  })  : _scriptureService = scriptureService,
        _postComposeService = postComposeService,
        super(const NewPostEditing()) {
    on<NewPostTypeChanged>(_onTypeChanged);
    on<ScriptureNotifyCommunityToggled>(_onNotifyCommunityToggled);
    on<NewPostMediaUpdated>(_onMediaUpdated);
    on<NewPostMediaCaptionChanged>(_onMediaCaptionChanged);
    on<ScripturePostPublishRequested>(_onPublishRequested);
    on<AttachmentPostPublishRequested>(_onAttachmentPublishRequested);
    on<NewPostEditingRestored>(_onEditingRestored);
  }

  void _onEditingRestored(
    NewPostEditingRestored event,
    Emitter<NewPostState> emit,
  ) {
    emit(event.editing);
  }

  NewPostEditing? get _editing => switch (state) {
        NewPostEditing() => state as NewPostEditing,
        NewPostFailure(:final previous) => previous,
        _ => null,
      };

  void _onTypeChanged(NewPostTypeChanged event, Emitter<NewPostState> emit) {
    final current = _editing;
    if (current == null) return;
    emit(
      current.copyWith(
        selectedType: event.type,
        clearUploadedMedia: true,
      ),
    );
  }

  void _onNotifyCommunityToggled(
    ScriptureNotifyCommunityToggled event,
    Emitter<NewPostState> emit,
  ) {
    final current = _editing;
    if (current == null) return;
    emit(current.copyWith(notifyCommunity: !current.notifyCommunity));
  }

  void _onMediaUpdated(
    NewPostMediaUpdated event,
    Emitter<NewPostState> emit,
  ) {
    final current = _editing;
    if (current == null) return;
    emit(
      current.copyWith(
        uploadedMedia: event.media,
        clearUploadedMedia: event.media == null,
      ),
    );
  }

  void _onMediaCaptionChanged(
    NewPostMediaCaptionChanged event,
    Emitter<NewPostState> emit,
  ) {
    final current = _editing;
    if (current == null) return;
    emit(current.copyWith(mediaCaption: event.caption));
  }

  Future<void> _onPublishRequested(
    ScripturePostPublishRequested event,
    Emitter<NewPostState> emit,
  ) async {
    final current = _editing;
    if (current == null) return;
    if (current.selectedType != NewPostType.scripture) return;

    final reference = event.bibleReference.trim();
    final verse = event.verseText.trim();

    emit(current.copyWith(isPublishing: true));

    final result = await _scriptureService.publishScripturePost(
      bibleReference: reference,
      verseText: verse,
      allowComments: false,
      notifyCommunity: current.notifyCommunity,
    );

    result.fold(
      (failure) => emit(
        NewPostFailure(
          failure.message,
          current.copyWith(isPublishing: false),
        ),
      ),
      (post) => emit(NewPostPublishSuccess(post)),
    );
  }

  Future<void> _onAttachmentPublishRequested(
    AttachmentPostPublishRequested event,
    Emitter<NewPostState> emit,
  ) async {
    final current = _editing;
    if (current == null) return;
    if (current.selectedType != NewPostType.attachment) return;

    final media = current.uploadedMedia;
    if (media == null) {
      emit(
        NewPostFailure(
          'Please attach an image or video.',
          current,
        ),
      );
      return;
    }

    emit(current.copyWith(isPublishing: true));

    final draft = PostComposeDraft(
      selectedType: PostComposeType.attachment,
      caption: current.mediaCaption,
      uploadedMedia: media,
      allowComments: false,
      notifyCommunity: current.notifyCommunity,
    );

    final result = await _postComposeService.publish(draft);

    result.fold(
      (failure) => emit(
        NewPostFailure(
          failure.message,
          current.copyWith(isPublishing: false),
        ),
      ),
      (postId) => emit(NewPostMediaPublishSuccess(postId)),
    );
  }
}
