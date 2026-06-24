import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/discovery/application/discovery_service.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_event.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_state.dart';

class NearbyBloc extends Bloc<NearbyEvent, NearbyState> {
  final DiscoveryService _discoveryService;
  NearbyChurchesFilter _filter = NearbyChurchesFilter.defaults();

  NearbyBloc({required DiscoveryService discoveryService})
      : _discoveryService = discoveryService,
        super(const NearbyInitial()) {
    on<NearbyRequested>(_onRequested);
    on<NearbyListRequested>(_onListRequested);
    on<NearbyRefreshed>(_onRefreshed);
    on<NearbyFilterChanged>(_onFilterChanged);
    on<NearbyFollowToggled>(_onFollowToggled);
    on<NearbyLoadMore>(_onLoadMore);
  }

  NearbyChurchesFilter get filter => _filter;

  Future<void> _onRequested(
    NearbyRequested event,
    Emitter<NearbyState> emit,
  ) async {
    if (state is NearbyLoaded || state is NearbyRefreshing) return;
    _filter = NearbyChurchesFilter.defaults();
    await _load(emit, showFullScreenLoading: true);
  }

  Future<void> _onListRequested(
    NearbyListRequested event,
    Emitter<NearbyState> emit,
  ) async {
    _filter = NearbyChurchesFilter.forListPage(
      radiusKm: _filter.clampedRadiusKm,
    );
    await _load(emit, showFullScreenLoading: true);
  }

  Future<void> _onRefreshed(
    NearbyRefreshed event,
    Emitter<NearbyState> emit,
  ) async {
    if (event.useHomePreview) {
      _filter = NearbyChurchesFilter.defaults();
    }
    final showLoading = event.useHomePreview &&
        state is! NearbyLoaded &&
        state is! NearbyRefreshing;
    await _load(emit, showFullScreenLoading: showLoading);
  }

  Future<void> _onFilterChanged(
    NearbyFilterChanged event,
    Emitter<NearbyState> emit,
  ) async {
    _filter = event.filter.pageSize >= NearbyChurchesFilter.maxPageSize
        ? event.filter
        : event.filter.copyWith(
            page: 1,
            pageSize: NearbyChurchesFilter.maxPageSize,
          );
    await _load(emit, showFullScreenLoading: false);
  }

  Future<void> _onLoadMore(
    NearbyLoadMore event,
    Emitter<NearbyState> emit,
  ) async {
    final currentResult = _currentResult();
    if (currentResult == null) return;
    
    final meta = currentResult.meta;
    if (meta == null || !meta.hasNextPage) return;
    if (state is NearbyPaginating || state is NearbyRefreshing || state is NearbyLoading) return;

    _filter = _filter.copyWith(page: _filter.page + 1);
    emit(NearbyPaginating(previous: currentResult, filter: _filter));

    final result = await _discoveryService.getNearbyChurches(filter: _filter);
    result.fold(
      (failure) {
        // Revert page filter and emit loaded state with old items
        _filter = _filter.copyWith(page: _filter.page - 1);
        emit(NearbyLoaded(currentResult));
      },
      (newResult) {
        // Append new items to old items
        final combinedChurches = [
          ...currentResult.churches,
          ...newResult.churches,
        ];
        
        final combinedResult = newResult.copyWith(
          churches: combinedChurches,
          areaLabel: currentResult.areaLabel,
        );
        
        emit(NearbyLoaded(combinedResult));
      },
    );
  }

  Future<void> _load(
    Emitter<NearbyState> emit, {
    required bool showFullScreenLoading,
  }) async {
    final previous = _currentResult();

    if (showFullScreenLoading || previous == null) {
      emit(NearbyLoading(filter: _filter));
    } else {
      emit(NearbyRefreshing(previous: previous, filter: _filter));
    }

    final result = await _discoveryService.getNearbyChurches(filter: _filter);
    result.fold(
      (failure) {
        if (previous != null && !showFullScreenLoading) {
          emit(NearbyLoaded(previous));
        } else {
          emit(NearbyFailure(failure.message));
        }
      },
      (data) => emit(NearbyLoaded(data)),
    );
  }

  NearbyChurchesResult? _currentResult() {
    return switch (state) {
      NearbyLoaded(:final result) => result,
      NearbyRefreshing(:final previous) => previous,
      NearbyPaginating(:final previous) => previous,
      _ => null,
    };
  }

  Future<void> _onFollowToggled(
    NearbyFollowToggled event,
    Emitter<NearbyState> emit,
  ) async {
    final current = state;
    final result = switch (current) {
      NearbyLoaded(:final result) => result,
      NearbyRefreshing(:final previous) => previous,
      NearbyPaginating(:final previous) => previous,
      _ => null,
    };
    if (result == null) return;

    final churches = result.churches
        .map(
          (c) => c.id == event.churchId
              ? c.copyWith(isFollowing: event.follow)
              : c,
        )
        .toList();

    final optimistic = NearbyChurchesResult(
      areaLabel: result.areaLabel,
      totalCount: result.totalCount,
      churches: churches,
      filter: result.filter,
    );

    if (current is NearbyRefreshing) {
      emit(NearbyRefreshing(previous: optimistic, filter: current.filter));
    } else if (current is NearbyPaginating) {
      emit(NearbyPaginating(previous: optimistic, filter: current.filter));
    } else {
      emit(NearbyLoaded(optimistic));
    }

    final toggle = await _discoveryService.toggleFollowChurch(
      churchId: event.churchId,
      follow: event.follow,
    );

    toggle.fold((_) {
      if (current is NearbyRefreshing) {
        emit(NearbyRefreshing(previous: result, filter: current.filter));
      } else if (current is NearbyPaginating) {
        emit(NearbyPaginating(previous: result, filter: current.filter));
      } else {
        emit(NearbyLoaded(result));
      }
    }, (_) {});
  }
}
