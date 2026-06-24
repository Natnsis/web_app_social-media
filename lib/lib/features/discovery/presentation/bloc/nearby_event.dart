import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';

sealed class NearbyEvent extends Equatable {
  const NearbyEvent();

  @override
  List<Object?> get props => [];
}

final class NearbyRequested extends NearbyEvent {
  const NearbyRequested();
}

final class NearbyRefreshed extends NearbyEvent {
  /// When true, reloads with home preview filters (`pageSize: 20`).
  final bool useHomePreview;

  const NearbyRefreshed({this.useHomePreview = false});

  @override
  List<Object?> get props => [useHomePreview];
}

final class NearbyListRequested extends NearbyEvent {
  const NearbyListRequested();
}

/// Triggers pagination to load the next page of results
final class NearbyLoadMore extends NearbyEvent {
  const NearbyLoadMore();
}

final class NearbyFilterChanged extends NearbyEvent {
  final NearbyChurchesFilter filter;

  const NearbyFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class NearbyFollowToggled extends NearbyEvent {
  final String churchId;
  final bool follow;

  const NearbyFollowToggled({
    required this.churchId,
    required this.follow,
  });

  @override
  List<Object?> get props => [churchId, follow];
}
