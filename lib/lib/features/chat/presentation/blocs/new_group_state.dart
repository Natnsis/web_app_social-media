import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';

sealed class NewGroupState extends Equatable {
  const NewGroupState();

  @override
  List<Object?> get props => [];
}

final class NewGroupInitial extends NewGroupState {
  const NewGroupInitial();
}

final class NewGroupLoading extends NewGroupState {
  const NewGroupLoading();
}

final class NewGroupEditing extends NewGroupState {
  final NewGroupDraft draft;
  final List<GroupModeratorCandidate> moderators;

  const NewGroupEditing({
    required this.draft,
    required this.moderators,
  });

  @override
  List<Object?> get props => [draft, moderators];
}

final class NewGroupSuccess extends NewGroupState {
  final String roomId;

  const NewGroupSuccess(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

final class NewGroupFailure extends NewGroupState {
  final NewGroupDraft draft;
  final List<GroupModeratorCandidate> moderators;
  final String message;

  const NewGroupFailure({
    required this.draft,
    required this.moderators,
    required this.message,
  });

  @override
  List<Object?> get props => [draft, moderators, message];
}
