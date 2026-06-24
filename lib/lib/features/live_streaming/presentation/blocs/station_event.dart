import 'package:equatable/equatable.dart';

sealed class StationEvent extends Equatable {
  const StationEvent();

  @override
  List<Object?> get props => [];
}

final class StationsRequested extends StationEvent {
  final int? limit;
  final int? offset;

  const StationsRequested({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

final class StationDetailRequested extends StationEvent {
  final String id;

  const StationDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class StationCreateRequested extends StationEvent {
  final String name;
  final String description;
  final String type;

  const StationCreateRequested({
    required this.name,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [name, description, type];
}

final class StationUpdateRequested extends StationEvent {
  final String novaStreamId;
  final String name;
  final String description;
  final String type;

  const StationUpdateRequested({
    required this.novaStreamId,
    required this.name,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [novaStreamId, name, description, type];
}

final class StationDeleteRequested extends StationEvent {
  final String novaStreamId;

  const StationDeleteRequested(this.novaStreamId);

  @override
  List<Object?> get props => [novaStreamId];
}
