import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/discovery/application/discovery_service.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/discovery_event.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryService _discoveryService;
  NearbyChurchesFilter _nearbyFilter = NearbyChurchesFilter.defaults();

  DiscoveryBloc({required DiscoveryService discoveryService})
      : _discoveryService = discoveryService,
        super(const DiscoveryInitial()) {
    on<DiscoveryRequested>(_onRequested);
    on<DiscoveryRefreshed>(_onRefreshed);
    on<DiscoveryNearbyFilterChanged>(_onNearbyFilterChanged);
    on<DiscoveryFollowToggled>(_onFollowToggled);
  }

  NearbyChurchesFilter get nearbyFilter => _nearbyFilter;

  Future<void> _onRequested(
    DiscoveryRequested event,
    Emitter<DiscoveryState> emit,
  ) async {
    await _load(emit, showLoading: true);
  }

  Future<void> _onRefreshed(
    DiscoveryRefreshed event,
    Emitter<DiscoveryState> emit,
  ) async {
    await _load(emit, showLoading: false);
  }

  Future<void> _onNearbyFilterChanged(
    DiscoveryNearbyFilterChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    _nearbyFilter = event.filter;
    await _load(emit, showLoading: true);
  }

  Future<void> _load(
    Emitter<DiscoveryState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) emit(const DiscoveryLoading());

    final result = await _discoveryService.getDiscoveryContent(
      nearbyFilter: _nearbyFilter,
    );
    result.fold(
      (failure) => emit(DiscoveryFailure(failure.message)),
      (content) => emit(DiscoveryLoaded(content)),
    );
  }

  Future<void> _onFollowToggled(
    DiscoveryFollowToggled event,
    Emitter<DiscoveryState> emit,
  ) async {
    final current = state;
    if (current is! DiscoveryLoaded) return;

    final optimistic = _updateFollow(
      current.content,
      event.churchId,
      event.follow,
    );
    emit(current.copyWith(content: optimistic));

    final result = await _discoveryService.toggleFollowChurch(
      churchId: event.churchId,
      follow: event.follow,
    );

    result.fold(
      (_) => emit(current),
      (_) {},
    );
  }

  DiscoveryContent _updateFollow(
    DiscoveryContent content,
    String churchId,
    bool follow,
  ) {
    List<DiscoveryNearbyChurch> mapChurches(List<DiscoveryNearbyChurch> list) {
      return list
          .map(
            (c) => c.id == churchId ? c.copyWith(isFollowing: follow) : c,
          )
          .toList();
    }

    return DiscoveryContent(
      nearby: mapChurches(content.nearby),
      liveNow: content.liveNow,
      trending: content.trending,
      suggested: content.suggested,
      campaigns: content.campaigns,
    );
  }
}
