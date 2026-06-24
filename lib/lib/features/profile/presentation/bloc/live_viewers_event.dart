import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';

sealed class LiveViewersEvent extends Equatable {
  const LiveViewersEvent();

  @override
  List<Object?> get props => [];
}

final class LiveViewersRequested extends LiveViewersEvent {
  const LiveViewersRequested();
}

final class LiveViewersRangeChanged extends LiveViewersEvent {
  final LiveViewersRange range;

  const LiveViewersRangeChanged(this.range);

  @override
  List<Object?> get props => [range];
}
