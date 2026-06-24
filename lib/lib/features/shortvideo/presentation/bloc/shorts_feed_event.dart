import 'package:equatable/equatable.dart';

sealed class ShortsFeedEvent extends Equatable {
  const ShortsFeedEvent();

  @override
  List<Object?> get props => [];
}

final class ShortsFeedRequested extends ShortsFeedEvent {
  const ShortsFeedRequested();
}

final class ShortsPageChanged extends ShortsFeedEvent {
  final int index;

  const ShortsPageChanged(this.index);

  @override
  List<Object?> get props => [index];
}

final class ShortVideoLikeToggled extends ShortsFeedEvent {
  final int index;

  const ShortVideoLikeToggled(this.index);

  @override
  List<Object?> get props => [index];
}

final class ShortVideoFollowToggled extends ShortsFeedEvent {
  final int index;

  const ShortVideoFollowToggled(this.index);

  @override
  List<Object?> get props => [index];
}

final class ShortVideoReflectionCountChanged extends ShortsFeedEvent {
  final int index;
  final int count;

  const ShortVideoReflectionCountChanged({
    required this.index,
    required this.count,
  });

  @override
  List<Object?> get props => [index, count];
}
