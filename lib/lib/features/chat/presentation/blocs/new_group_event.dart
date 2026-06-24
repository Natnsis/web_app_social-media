import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';

sealed class NewGroupEvent extends Equatable {
  const NewGroupEvent();

  @override
  List<Object?> get props => [];
}

final class NewGroupStarted extends NewGroupEvent {
  const NewGroupStarted();
}

final class NewGroupDraftUpdated extends NewGroupEvent {
  final NewGroupDraft draft;

  const NewGroupDraftUpdated(this.draft);

  @override
  List<Object?> get props => [draft];
}

final class NewGroupModeratorToggled extends NewGroupEvent {
  final String moderatorId;

  const NewGroupModeratorToggled(this.moderatorId);

  @override
  List<Object?> get props => [moderatorId];
}

final class NewGroupSubmitted extends NewGroupEvent {
  const NewGroupSubmitted();
}
