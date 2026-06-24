import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_summary.dart';

sealed class LiveViewersState extends Equatable {
  const LiveViewersState();

  @override
  List<Object?> get props => [];
}

final class LiveViewersInitial extends LiveViewersState {
  const LiveViewersInitial();
}

final class LiveViewersLoading extends LiveViewersState {
  final LiveViewersRange range;

  const LiveViewersLoading({this.range = LiveViewersRange.sixHours});

  @override
  List<Object?> get props => [range];
}

final class LiveViewersLoaded extends LiveViewersState {
  final LiveViewersSummary summary;

  const LiveViewersLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

final class LiveViewersFailure extends LiveViewersState {
  final String message;

  const LiveViewersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
