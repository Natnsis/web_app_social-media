import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';

sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

final class DiscoveryRequested extends DiscoveryEvent {
  const DiscoveryRequested();
}

final class DiscoveryRefreshed extends DiscoveryEvent {
  const DiscoveryRefreshed();
}

final class DiscoveryNearbyFilterChanged extends DiscoveryEvent {
  final NearbyChurchesFilter filter;

  const DiscoveryNearbyFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class DiscoveryFollowToggled extends DiscoveryEvent {
  final String churchId;
  final bool follow;

  const DiscoveryFollowToggled({
    required this.churchId,
    required this.follow,
  });

  @override
  List<Object?> get props => [churchId, follow];
}
