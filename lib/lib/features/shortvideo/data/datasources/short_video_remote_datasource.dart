import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/comment/data/dto/comment_api_dto.dart';
import 'package:faithconnect/features/comment/data/mappers/comment_mapper.dart';
import 'package:faithconnect/features/shortvideo/data/dto/short_api_dto.dart';
import 'package:faithconnect/features/shortvideo/data/mappers/short_video_mapper.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/quick_reaction.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflections_feed.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/shorts_query_filter.dart';

abstract class ShortVideoRemoteDataSource {
  Future<List<ShortVideo>> getShortVideos({
    ShortsQueryFilter filter = const ShortsQueryFilter(),
  });

  Future<ReflectionsFeed> getReflections(String shortVideoId);

  Future<Reflection> addReflection({
    required String shortVideoId,
    required String text,
    String? parentCommentId,
  });

  Future<void> deleteReflection(String shortVideoId, String commentId);

  Future<void> deleteShort(String shortId);

  Future<void> updateShort({
    required String shortId,
    required String title,
  });
}

class ShortVideoRemoteDataSourceImpl implements ShortVideoRemoteDataSource {
  ShortVideoRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<ShortVideo>> getShortVideos({
    ShortsQueryFilter filter = const ShortsQueryFilter(),
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ShortsApiEndpoint.list,
        queryParameters: filter.toQueryParameters(),
      );

      final parsed = ApiListResponse.parse(
        response.data,
        ShortApiDto.fromJson,
      );

      return parsed.data
          .where((dto) => dto.id.isNotEmpty)
          .map(ShortVideoMapper.fromDto)
          .toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<ReflectionsFeed> getReflections(String shortVideoId) async {
    try {
      final response = await _dio.get<dynamic>(
        '${ShortsApiEndpoint.detail(shortVideoId)}/comments',
      );

      final dtos = CommentApiDto.flattenList(response.data);
      final actorIds = await CommentMapper.currentActorIds();
      final reflections = CommentMapper.buildReflectionTree(
        dtos,
        currentUserId: actorIds.userId,
        currentChurchId: actorIds.churchId,
      );

      final parsed = ApiListResponse.parse(
        response.data,
        CommentApiDto.fromJson,
      );
      final total = parsed.meta.total > 0 ? parsed.meta.total : dtos.length;

      return ReflectionsFeed(
        totalReflecting: total,
        quickReactions: const [
          QuickReaction(emoji: '🙏', label: 'Amen'),
          QuickReaction(emoji: '✨', label: 'Be Blessed'),
          QuickReaction(emoji: '🙌', label: 'ተባረኩ!'),
          QuickReaction(emoji: '🎵', label: 'Hallelujah'),
        ],
        reflections: reflections,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }


  @override
  Future<Reflection> addReflection({
    required String shortVideoId,
    required String text,
    String? parentCommentId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('Reflection text is required.');
    }

    try {
      final form = FormData();
      form.fields.add(MapEntry('body', trimmed));
      if (parentCommentId != null && parentCommentId.isNotEmpty) {
        // API field is `parentId` — the UUID of the comment/reply being replied to.
        form.fields.add(MapEntry('parentId', parentCommentId));
      }

      final response = await _dio.post<dynamic>(
        '${ShortsApiEndpoint.detail(shortVideoId)}/comments',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      final dto = CommentApiDto.parseResponse(response.data);
      final actorIds = await CommentMapper.currentActorIds();
      return CommentMapper.toReflection(
        dto,
        currentUserId: actorIds.userId,
        currentChurchId: actorIds.churchId,
      ).copyWith(isOwnedByMe: true);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> deleteReflection(String shortVideoId, String commentId) async {
    try {
      await _dio.delete<dynamic>(ShortsApiEndpoint.deleteComment(shortVideoId, commentId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> deleteShort(String shortId) async {
    try {
      await _dio.delete<dynamic>(ShortsApiEndpoint.detail(shortId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> updateShort({
    required String shortId,
    required String title,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('Short caption is required.');
    }

    try {
      await _dio.patch<dynamic>(
        ShortsApiEndpoint.detail(shortId),
        data: {
          'title': trimmed,
          'description': trimmed,
        },
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
