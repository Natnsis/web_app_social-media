import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeFeedRequested extends HomeEvent {
  const HomeFeedRequested();
}

final class HomeFeedRefreshed extends HomeEvent {
  const HomeFeedRefreshed();
}

final class HomeFeedBackgroundRefreshed extends HomeEvent {
  const HomeFeedBackgroundRefreshed();
}

final class HomeFeedApplyUpdates extends HomeEvent {
  const HomeFeedApplyUpdates();
}
