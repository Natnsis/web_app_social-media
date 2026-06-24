import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/station_repository.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/station_event.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/station_state.dart';

class StationBloc extends Bloc<StationEvent, StationState> {
  final StationRepository repository;

  StationBloc({required this.repository}) : super(const StationInitial()) {
    on<StationsRequested>(_onStationsRequested);
    on<StationDetailRequested>(_onStationDetailRequested);
    on<StationCreateRequested>(_onStationCreateRequested);
    on<StationUpdateRequested>(_onStationUpdateRequested);
    on<StationDeleteRequested>(_onStationDeleteRequested);
  }

  Future<void> _onStationsRequested(
    StationsRequested event,
    Emitter<StationState> emit,
  ) async {
    emit(const StationLoading());

    final result = await repository.getStations(
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(StationError(failure.message)),
      (stations) => emit(StationsLoaded(stations)),
    );
  }

  Future<void> _onStationDetailRequested(
    StationDetailRequested event,
    Emitter<StationState> emit,
  ) async {
    emit(const StationLoading());

    final result = await repository.getStationById(event.id);

    result.fold(
      (failure) => emit(StationError(failure.message)),
      (station) => emit(StationDetailLoaded(station)),
    );
  }

  Future<void> _onStationCreateRequested(
    StationCreateRequested event,
    Emitter<StationState> emit,
  ) async {
    emit(const StationLoading());

    final result = await repository.createStation(
      name: event.name,
      description: event.description,
      type: event.type,
    );

    result.fold(
      (failure) => emit(StationError(failure.message)),
      (station) => emit(StationCreated(station)),
    );
  }

  Future<void> _onStationUpdateRequested(
    StationUpdateRequested event,
    Emitter<StationState> emit,
  ) async {
    emit(const StationLoading());

    final result = await repository.updateStation(
      novaStreamId: event.novaStreamId,
      name: event.name,
      description: event.description,
      type: event.type,
    );

    result.fold(
      (failure) => emit(StationError(failure.message)),
      (station) => emit(StationUpdated(station)),
    );
  }

  Future<void> _onStationDeleteRequested(
    StationDeleteRequested event,
    Emitter<StationState> emit,
  ) async {
    final result = await repository.deleteStation(event.novaStreamId);

    result.fold(
      (failure) => emit(StationError(failure.message)),
      (_) => emit(const StationDeleted()),
    );
  }
}
