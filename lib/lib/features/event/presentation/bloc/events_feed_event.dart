import 'package:equatable/equatable.dart';

sealed class EventsFeedEvent extends Equatable {
  const EventsFeedEvent();

  @override
  List<Object?> get props => [];
}

final class EventsFeedRequested extends EventsFeedEvent {
  const EventsFeedRequested();
}

final class EventsFeedRefreshed extends EventsFeedEvent {
  const EventsFeedRefreshed();
}
