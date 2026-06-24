import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';

sealed class EventsFeedState extends Equatable {
  const EventsFeedState();

  @override
  List<Object?> get props => [];
}

final class EventsFeedInitial extends EventsFeedState {
  const EventsFeedInitial();
}

final class EventsFeedLoading extends EventsFeedState {
  const EventsFeedLoading();
}

final class EventsFeedLoaded extends EventsFeedState {
  final List<ChurchEvent> events;

  const EventsFeedLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

final class EventsFeedFailure extends EventsFeedState {
  final String message;

  const EventsFeedFailure(this.message);

  @override
  List<Object?> get props => [message];
}
