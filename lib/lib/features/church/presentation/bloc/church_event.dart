import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_tab.dart';

sealed class ChurchEvent extends Equatable {
  const ChurchEvent();

  @override
  List<Object?> get props => [];
}

final class ChurchProfileRequested extends ChurchEvent {
  final String profileId;

  const ChurchProfileRequested(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

final class ChurchProfileRefreshed extends ChurchEvent {
  final String profileId;

  const ChurchProfileRefreshed(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

final class ChurchProfileTabChanged extends ChurchEvent {
  final ChurchProfileTab tab;

  const ChurchProfileTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

final class ChurchProfileFollowToggled extends ChurchEvent {
  const ChurchProfileFollowToggled();
}

final class ChurchProfileUnfollowRequested extends ChurchEvent {
  const ChurchProfileUnfollowRequested();
}

final class ChurchFollowActionCleared extends ChurchEvent {
  const ChurchFollowActionCleared();
}
