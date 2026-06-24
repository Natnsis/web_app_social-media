import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/domain/entities/home_feed.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final HomeFeed feed;
  final HomeFeed? pendingFeed;
  final bool? hasUpdatesAvailable;

  const HomeLoaded(
    this.feed, {
    this.pendingFeed,
    this.hasUpdatesAvailable = false,
  });

  HomeLoaded copyWith({
    HomeFeed? feed,
    HomeFeed? pendingFeed,
    bool? hasUpdatesAvailable,
  }) {
    return HomeLoaded(
      feed ?? this.feed,
      pendingFeed: pendingFeed ?? this.pendingFeed,
      hasUpdatesAvailable: hasUpdatesAvailable ?? this.hasUpdatesAvailable,
    );
  }

  @override
  List<Object?> get props => [feed, pendingFeed, hasUpdatesAvailable];
}

final class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
