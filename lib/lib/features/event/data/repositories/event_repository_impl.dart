import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/event/data/datasources/event_remote_datasource.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:faithconnect/features/event/domain/entities/events_query_filter.dart';
import 'package:faithconnect/features/event/domain/repositories/event_repository.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl({required EventRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final EventRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<ChurchEvent>>> fetchEvents({
    EventsQueryFilter filter = const EventsQueryFilter(),
  }) async {
    try {
      final events = await _remoteDataSource.fetchEvents(filter: filter);
      return Right(events);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createEvent(PostComposeDraft draft) async {
    try {
      final id = await _remoteDataSource.createEvent(draft);
      return Right(id);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateEvent({
    required String eventId,
    required String title,
    String? date,
    String? time,
    String? details,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) async {
    try {
      await _remoteDataSource.updateEvent(
        eventId: eventId,
        title: title,
        date: date,
        time: time,
        details: details,
        newMedia: newMedia,
        removeExistingMedia: removeExistingMedia,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      await _remoteDataSource.deleteEvent(eventId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
