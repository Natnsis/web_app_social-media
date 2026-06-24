import 'package:equatable/equatable.dart';

sealed class ChurchModeratorsEvent extends Equatable {
  const ChurchModeratorsEvent();

  @override
  List<Object?> get props => [];
}

final class ChurchModeratorsRequested extends ChurchModeratorsEvent {
  const ChurchModeratorsRequested();
}

final class ChurchModeratorAssignSubmitted extends ChurchModeratorsEvent {
  final String userId;

  const ChurchModeratorAssignSubmitted(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class ChurchModeratorRevokeSubmitted extends ChurchModeratorsEvent {
  final String userId;

  const ChurchModeratorRevokeSubmitted(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class ChurchModeratorUserSearchRequested extends ChurchModeratorsEvent {
  final String query;

  const ChurchModeratorUserSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}
