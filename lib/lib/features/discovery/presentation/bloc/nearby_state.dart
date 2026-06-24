import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_meta.dart';

sealed class NearbyState extends Equatable {
  const NearbyState();

  List<DiscoveryNearbyChurch> get churches => const [];
  NearbyChurchesMeta? get meta => null;

  @override
  List<Object?> get props => [];
}

final class NearbyInitial extends NearbyState {
  const NearbyInitial();
}

final class NearbyLoading extends NearbyState {
  final NearbyChurchesFilter filter;

  const NearbyLoading({required this.filter});

  @override
  List<Object?> get props => [filter];
}

final class NearbyRefreshing extends NearbyState {
  final NearbyChurchesResult previous;
  final NearbyChurchesFilter filter;

  const NearbyRefreshing({
    required this.previous,
    required this.filter,
  });

  @override
  List<DiscoveryNearbyChurch> get churches => previous.churches;

  @override
  NearbyChurchesMeta? get meta => previous.meta;

  @override
  List<Object?> get props => [previous, filter];
}

final class NearbyPaginating extends NearbyState {
  final NearbyChurchesResult previous;
  final NearbyChurchesFilter filter;

  const NearbyPaginating({
    required this.previous,
    required this.filter,
  });

  @override
  List<DiscoveryNearbyChurch> get churches => previous.churches;

  @override
  NearbyChurchesMeta? get meta => previous.meta;

  @override
  List<Object?> get props => [previous, filter];
}

final class NearbyLoaded extends NearbyState {
  final NearbyChurchesResult result;

  const NearbyLoaded(this.result);

  @override
  List<DiscoveryNearbyChurch> get churches => result.churches;

  @override
  NearbyChurchesMeta? get meta => result.meta;

  NearbyLoaded copyWith({NearbyChurchesResult? result}) {
    return NearbyLoaded(result ?? this.result);
  }

  @override
  List<Object?> get props => [result];
}

final class NearbyFailure extends NearbyState {
  final String message;

  const NearbyFailure(this.message);

  @override
  List<Object?> get props => [message];
}
