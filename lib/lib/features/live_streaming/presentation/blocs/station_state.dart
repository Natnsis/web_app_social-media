import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/station.dart';

sealed class StationState extends Equatable {
  const StationState();

  @override
  List<Object?> get props => [];
}

final class StationInitial extends StationState {
  const StationInitial();
}

final class StationLoading extends StationState {
  const StationLoading();
}

final class StationsLoaded extends StationState {
  final List<Station> stations;

  const StationsLoaded(this.stations);

  @override
  List<Object?> get props => [stations];
}

final class StationDetailLoaded extends StationState {
  final Station station;

  const StationDetailLoaded(this.station);

  @override
  List<Object?> get props => [station];
}

final class StationCreated extends StationState {
  final Station station;

  const StationCreated(this.station);

  @override
  List<Object?> get props => [station];
}

final class StationUpdated extends StationState {
  final Station station;

  const StationUpdated(this.station);

  @override
  List<Object?> get props => [station];
}

final class StationDeleted extends StationState {
  const StationDeleted();
}

final class StationError extends StationState {
  final String message;

  const StationError(this.message);

  @override
  List<Object?> get props => [message];
}
