import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/profile/application/profile_service.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';
import 'package:faithconnect/features/profile/presentation/bloc/live_viewers_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/live_viewers_state.dart';

class LiveViewersBloc extends Bloc<LiveViewersEvent, LiveViewersState> {
  final ProfileService _profileService;

  LiveViewersBloc({required ProfileService profileService})
      : _profileService = profileService,
        super(const LiveViewersInitial()) {
    on<LiveViewersRequested>(_onRequested);
    on<LiveViewersRangeChanged>(_onRangeChanged);
  }

  Future<void> _onRequested(
    LiveViewersRequested event,
    Emitter<LiveViewersState> emit,
  ) async {
    await _load(LiveViewersRange.sixHours, emit);
  }

  Future<void> _onRangeChanged(
    LiveViewersRangeChanged event,
    Emitter<LiveViewersState> emit,
  ) async {
    await _load(event.range, emit);
  }

  Future<void> _load(
    LiveViewersRange range,
    Emitter<LiveViewersState> emit,
  ) async {
    emit(LiveViewersLoading(range: range));
    final result = await _profileService.getLiveViewersSummary(range);
    result.fold(
      (failure) => emit(LiveViewersFailure(failure.message)),
      (summary) => emit(LiveViewersLoaded(summary)),
    );
  }
}
