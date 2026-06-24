import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/comment/data/dto/comment_api_dto.dart';
import 'package:faithconnect/features/comment/data/dto/comment_like_result_dto.dart';
import 'package:faithconnect/features/comment/data/dto/create_comment_reply_dto.dart';
import 'package:faithconnect/features/comment/domain/entities/comment_like_state.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentApiDto>> fetchCommentReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  });

  Future<CommentApiDto> replyToComment({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  });

  Future<CommentApiDto> updateComment({
    required String commentId,
    required String body,
  });

  Future<CommentLikeState> likeComment(String commentId);

  Future<CommentLikeState> unlikeComment(String commentId);

  Future<void> deleteComment(String commentId);
}

class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  CommentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<CommentApiDto> updateComment({
    required String commentId,
    required String body,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('Comment text is required.');
    }

    try {
      final response = await _dio.patch<dynamic>(
        CommentsApiEndpoint.detail(commentId),
        data: {'body': trimmed},
      );
      return CommentApiDto.parseResponse(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<List<CommentApiDto>> fetchCommentReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        CommentsApiEndpoint.replies(parentCommentId),
        queryParameters: {
          'skip': skip,
          'take': take,
        },
      );

      return CommentApiDto.flattenList(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<CommentApiDto> replyToComment({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('Reply text is required.');
    }

    try {
      final payload = CreateCommentReplyDto(
        body: trimmed,
        mediaPath: mediaPath,
      );

      final response = await _dio.post<dynamic>(
        CommentsApiEndpoint.replies(parentCommentId),
        data: await payload.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      return CommentApiDto.parseResponse(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<CommentLikeState> likeComment(String commentId) async {
    try {
      final response = await _dio.post<dynamic>(
        CommentsApiEndpoint.like(commentId),
      );
      return CommentLikeResultDto.parseResponse(
        response.data,
        liked: true,
      ).toEntity();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<CommentLikeState> unlikeComment(String commentId) async {
    try {
      final response = await _dio.delete<dynamic>(
        CommentsApiEndpoint.like(commentId),
      );
      return CommentLikeResultDto.parseResponse(
        response.data,
        liked: false,
      ).toEntity();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await _dio.delete<void>(CommentsApiEndpoint.detail(commentId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
