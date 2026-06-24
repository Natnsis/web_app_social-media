import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_create_response.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/event/data/dto/event_api_dto.dart';
import 'package:faithconnect/features/event/data/mappers/create_event_mapper.dart';
import 'package:faithconnect/features/event/data/mappers/event_mapper.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:faithconnect/features/event/domain/entities/events_query_filter.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'dart:io';

abstract class EventRemoteDataSource {
  Future<List<ChurchEvent>> fetchEvents({
    EventsQueryFilter filter = const EventsQueryFilter(),
  });

  Future<String> createEvent(PostComposeDraft draft);

  Future<void> updateEvent({
    required String eventId,
    required String title,
    String? date,
    String? time,
    String? details,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  });

  Future<void> deleteEvent(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  EventRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<ChurchEvent>> fetchEvents({
    EventsQueryFilter filter = const EventsQueryFilter(),
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        EventsApiEndpoint.list,
        queryParameters: filter.toQueryParameters(),
      );

      final parsed = ApiListResponse.parse(
        response.data,
        EventApiDto.fromJson,
      );

      return parsed.data
          .where((dto) => dto.id.isNotEmpty)
          .map(EventMapper.fromDto)
          .toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<String> createEvent(PostComposeDraft draft) async {
    final payload = CreateEventMapper.fromComposeDraft(draft);

    if (payload.title.isEmpty) {
      throw const AuthException('Event title is required.');
    }
    if (payload.date.isEmpty) {
      throw const AuthException('Please select a valid event date.');
    }
    if (payload.time.isEmpty) {
      throw const AuthException('Please select a valid event time.');
    }

    try {
      final response = await _dio.post<dynamic>(
        EventsApiEndpoint.list,
        data: await payload.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      return ApiCreateResponse.parseId(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> updateEvent({
    required String eventId,
    required String title,
    String? date,
    String? time,
    String? details,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) async {
    try {
      final form = FormData();
      form.fields.add(MapEntry('title', title));
      if (date != null) form.fields.add(MapEntry('date', date));
      if (time != null) form.fields.add(MapEntry('time', time));
      if (details != null) form.fields.add(MapEntry('description', details));

      if (newMedia != null) {
        final path = newMedia.filePath;
        final file = File(path);
        if (await file.exists()) {
          final segments = path.split(Platform.pathSeparator);
          final filename = segments.isNotEmpty ? segments.last : 'cover.jpg';
          form.files.add(
            MapEntry(
              'image',
              await MultipartFile.fromFile(path, filename: filename),
            ),
          );
        }
      } else if (removeExistingMedia) {
        form.fields.add(const MapEntry('image', ''));
      }

      await _dio.patch<dynamic>(
        EventsApiEndpoint.detail(eventId),
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _dio.delete<void>(
        EventsApiEndpoint.detail(eventId),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
