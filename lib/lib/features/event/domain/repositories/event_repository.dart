import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:faithconnect/features/event/domain/entities/events_query_filter.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';

abstract class EventRepository {
  Future<Either<Failure, List<ChurchEvent>>> fetchEvents({
    EventsQueryFilter filter = const EventsQueryFilter(),
  });

  Future<Either<Failure, String>> createEvent(PostComposeDraft draft);

  Future<Either<Failure, void>> updateEvent({
    required String eventId,
    required String title,
    String? date,
    String? time,
    String? details,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  });

  Future<Either<Failure, void>> deleteEvent(String eventId);
}
