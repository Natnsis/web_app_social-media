import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';

sealed class FollowingEvent extends Equatable {
  const FollowingEvent();

  @override
  List<Object?> get props => [];
}

final class FollowingRequested extends FollowingEvent {
  const FollowingRequested();
}

final class FollowingPeriodChanged extends FollowingEvent {
  final GiftPeriod period;

  const FollowingPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

final class FollowingLoadMore extends FollowingEvent {
  const FollowingLoadMore();
}

final class FollowingUnfollowToggled extends FollowingEvent {
  final String churchId;

  const FollowingUnfollowToggled(this.churchId);

  @override
  List<Object?> get props => [churchId];
}
