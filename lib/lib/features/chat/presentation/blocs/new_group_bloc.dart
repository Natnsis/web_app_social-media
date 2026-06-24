import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/chat/application/chat_service.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';
import 'package:faithconnect/features/chat/presentation/blocs/new_group_event.dart';
import 'package:faithconnect/features/chat/presentation/blocs/new_group_state.dart';

class NewGroupBloc extends Bloc<NewGroupEvent, NewGroupState> {
  final ChatService _chatService;

  NewGroupBloc({required ChatService chatService})
      : _chatService = chatService,
        super(const NewGroupInitial()) {
    on<NewGroupStarted>(_onStarted);
    on<NewGroupDraftUpdated>(_onDraftUpdated);
    on<NewGroupModeratorToggled>(_onModeratorToggled);
    on<NewGroupSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    NewGroupStarted event,
    Emitter<NewGroupState> emit,
  ) async {
    emit(const NewGroupLoading());
    final result = await _chatService.getModeratorCandidates();
    result.fold(
      (failure) => emit(
        NewGroupFailure(
          draft: const NewGroupDraft(),
          moderators: const [],
          message: failure.message,
        ),
      ),
      (moderators) => emit(
        NewGroupEditing(
          draft: const NewGroupDraft(),
          moderators: moderators,
        ),
      ),
    );
  }

  void _onDraftUpdated(
    NewGroupDraftUpdated event,
    Emitter<NewGroupState> emit,
  ) {
    final current = _editingState;
    if (current == null) return;
    emit(NewGroupEditing(draft: event.draft, moderators: current.moderators));
  }

  void _onModeratorToggled(
    NewGroupModeratorToggled event,
    Emitter<NewGroupState> emit,
  ) {
    final current = _editingState;
    if (current == null) return;

    final ids = Set<String>.from(current.draft.selectedModeratorIds);
    if (ids.contains(event.moderatorId)) {
      ids.remove(event.moderatorId);
    } else {
      ids.add(event.moderatorId);
    }

    emit(
      NewGroupEditing(
        draft: current.draft.copyWith(selectedModeratorIds: ids),
        moderators: current.moderators,
      ),
    );
  }

  Future<void> _onSubmitted(
    NewGroupSubmitted event,
    Emitter<NewGroupState> emit,
  ) async {
    final current = _editingState;
    if (current == null) return;

    final validation = _validate(current.draft);
    if (validation != null) {
      emit(
        NewGroupFailure(
          draft: current.draft,
          moderators: current.moderators,
          message: validation,
        ),
      );
      return;
    }

    final submitting = current.draft.copyWith(isSubmitting: true);
    emit(NewGroupEditing(draft: submitting, moderators: current.moderators));

    final result = await _chatService.createGroup(submitting);
    result.fold(
      (failure) => emit(
        NewGroupFailure(
          draft: submitting.copyWith(isSubmitting: false),
          moderators: current.moderators,
          message: failure.message,
        ),
      ),
      (roomId) => emit(NewGroupSuccess(roomId)),
    );
  }

  NewGroupEditing? get _editingState => switch (state) {
        NewGroupEditing() => state as NewGroupEditing,
        NewGroupFailure(:final draft, :final moderators) => NewGroupEditing(
            draft: draft,
            moderators: moderators,
          ),
        _ => null,
      };

  String? _validate(NewGroupDraft draft) {
    if (draft.name.trim().isEmpty) {
      return 'Group name is required.';
    }
    return null;
  }
}
