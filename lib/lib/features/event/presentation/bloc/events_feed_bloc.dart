import 'package:faithconnect/features/event/application/event_service.dart';
import 'package:faithconnect/features/event/domain/entities/events_query_filter.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_event.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsFeedBloc extends Bloc<EventsFeedEvent, EventsFeedState> {
  final EventService _eventService;

  EventsFeedBloc({required EventService eventService})
      : _eventService = eventService,
        super(const EventsFeedInitial()) {
    on<EventsFeedRequested>(_onRequested);
    on<EventsFeedRefreshed>(_onRefreshed);
  }

  Future<void> _onRequested(
    EventsFeedRequested event,
    Emitter<EventsFeedState> emit,
  ) async {
    emit(const EventsFeedLoading());
    await _load(emit);
  }

  Future<void> _onRefreshed(
    EventsFeedRefreshed event,
    Emitter<EventsFeedState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<EventsFeedState> emit) async {
    final result = await _eventService.fetchEvents(
      filter: EventsQueryFilter.defaults(),
    );

    result.fold(
      (failure) => emit(EventsFeedFailure(failure.message)),
      (events) => emit(EventsFeedLoaded(events: events)),
    );
  }
}
