import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:faithconnect/features/event/domain/entities/events_query_filter.dart';
import 'package:faithconnect/features/event/domain/repositories/event_repository.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';

class EventService {
  final EventRepository _repository;

  EventService(this._repository);

  Future<Either<Failure, List<ChurchEvent>>> fetchEvents({
    EventsQueryFilter filter = const EventsQueryFilter(),
  }) =>
      _repository.fetchEvents(filter: filter);

  Future<Either<Failure, String>> createEvent(PostComposeDraft draft) =>
      _repository.createEvent(draft);

  Future<Either<Failure, void>> updateEvent({
    required String eventId,
    required String title,
    String? date,
    String? time,
    String? details,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) =>
      _repository.updateEvent(
        eventId: eventId,
        title: title,
        date: date,
        time: time,
        details: details,
        newMedia: newMedia,
        removeExistingMedia: removeExistingMedia,
      );

  Future<Either<Failure, void>> deleteEvent(String eventId) =>
      _repository.deleteEvent(eventId);
}
