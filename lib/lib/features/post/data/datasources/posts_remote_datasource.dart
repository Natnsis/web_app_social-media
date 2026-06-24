import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/home/data/models/post_model.dart';
import 'package:faithconnect/features/post/data/dto/post_api_dto.dart';
import 'package:faithconnect/features/post/domain/entities/posts_query_filter.dart';

class PostsPageResult {
  final List<PostModel> posts;
  final ApiListMeta meta;

  const PostsPageResult({
    required this.posts,
    required this.meta,
  });
}

abstract class PostsRemoteDataSource {
  Future<PostsPageResult> fetchPosts({
    PostsQueryFilter filter = const PostsQueryFilter(),
  });

  Future<PostsPageResult> fetchSavedPosts({
    PostsQueryFilter filter = const PostsQueryFilter(),
  });
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  PostsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<PostsPageResult> fetchPosts({
    PostsQueryFilter filter = const PostsQueryFilter(),
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        PostsApiEndpoint.list,
        queryParameters: filter.toQueryParameters(),
      );

      final parsed = ApiListResponse.parse(
        response.data,
        PostApiDto.fromJson,
      );

      final posts = parsed.data
          .where((p) => p.id.isNotEmpty)
          .map((p) => p.toPostModel())
          .toList();

      return PostsPageResult(posts: posts, meta: parsed.meta);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<PostsPageResult> fetchSavedPosts({
    PostsQueryFilter filter = const PostsQueryFilter(),
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        PostsApiEndpoint.saved,
        queryParameters: filter.toQueryParameters(),
      );

      final parsed = ApiListResponse.parse(
        response.data,
        PostApiDto.fromJson,
      );

      final posts = parsed.data
          .where((p) => p.id.isNotEmpty)
          .map((p) => p.toPostModel(forceSaved: true))
          .toList();

      return PostsPageResult(posts: posts, meta: parsed.meta);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
