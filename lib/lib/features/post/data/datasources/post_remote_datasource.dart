import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/network/api_create_response.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/comment/data/dto/comment_api_dto.dart';
import 'package:faithconnect/features/comment/data/mappers/comment_mapper.dart';
import 'package:faithconnect/features/post/data/dto/post_api_dto.dart';
import 'package:faithconnect/features/post/data/dto/post_like_result_dto.dart';
import 'package:faithconnect/features/post/data/dto/create_post_dto.dart';
import 'package:faithconnect/features/post/domain/entities/post_like_state.dart';
import 'package:faithconnect/features/post/data/mappers/create_post_mapper.dart';
import 'package:faithconnect/features/post/data/mappers/create_short_mapper.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_detail.dart';
import 'package:faithconnect/core/utils/media_url_resolver.dart';

abstract class PostRemoteDataSource {
  Future<PostDetail> getPostDetail(String postId);

  Future<List<PostComment>> fetchPostComments(String postId);

  Future<PostComment> addComment({
    required String postId,
    required String text,
  });

  Future<String> createTextPost(PostComposeDraft draft);

  Future<String> createShort(PostComposeDraft draft);

  Future<String> publishComposeStub(PostComposeDraft draft);

  Future<PostLikeState> likePost(String postId);

  Future<PostLikeState> unlikePost(String postId);

  Future<void> deletePost(String postId);

  Future<void> savePost(String postId);

  Future<void> unsavePost(String postId);

  Future<void> updatePost({
    required String postId,
    required String content,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<PostDetail> getPostDetail(String postId) async {
    try {
      final comments = await fetchPostComments(postId);

      final postResponse = await _dio.get<dynamic>(
        PostsApiEndpoint.detail(postId),
      );

      final postRoot = postResponse.data as Map<String, dynamic>? ?? {};
      final postData = postRoot['data'] as Map<String, dynamic>? ?? postRoot;
      final postDto = PostApiDto.fromJson(postData);
      final post = postDto.toPostModel();

      final isLiked =
          postData['isLikedByMe'] == true ||
          postData['isLiked'] == true ||
          postData['isLikedByCurrentUser'] == true;
      final isSaved =
          postData['isSavedByMe'] == true ||
          postData['isSaved'] == true ||
          postData['isSavedByCurrentUser'] == true;
      final isFollowingAuthor =
          postData['isFollowingAuthor'] == true ||
          postData['isFollowing'] == true ||
          postData['isFollowingByMe'] == true;
      final locationLabel =
          postData['locationLabel'] as String? ??
          postData['location'] as String?;

      return PostDetail(
        post: post,
        locationLabel: locationLabel,
        isFollowingAuthor: isFollowingAuthor,
        isLiked: isLiked,
        isSaved: isSaved,
        comments: comments,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<List<PostComment>> fetchPostComments(String postId) async {
    try {
      final response = await _dio.get<dynamic>(
        PostsApiEndpoint.comments(postId),
      );

      final dtos = CommentApiDto.flattenList(response.data);
      final actorIds = await CommentMapper.currentActorIds();
      return _buildCommentTree(
        dtos,
        currentUserId: actorIds.userId,
        currentChurchId: actorIds.churchId,
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  List<PostComment> _buildCommentTree(
    List<CommentApiDto> dtos, {
    String? currentUserId,
    String? currentChurchId,
  }) {
    final Map<String, List<PostComment>> childrenMap = {};
    final Map<String, CommentApiDto> dtoMap = {
      for (final dto in dtos) dto.id: dto,
    };

    PostComment mapDto(CommentApiDto dto) => CommentMapper.toPostComment(
      dto,
      currentUserId: currentUserId,
      currentChurchId: currentChurchId,
    );

    for (final dto in dtos) {
      if (dto.parentId != null && dto.parentId!.isNotEmpty) {
        childrenMap.putIfAbsent(dto.parentId!, () => []).add(mapDto(dto));
      }
    }

    PostComment buildNode(CommentApiDto dto) {
      final children = childrenMap[dto.id] ?? [];
      final recursivelyBuiltChildren = children.map((c) {
        final childDto = dtoMap[c.id];
        if (childDto != null) {
          return buildNode(childDto);
        }
        return c;
      }).toList();

      return mapDto(dto).copyWith(replies: recursivelyBuiltChildren);
    }

    final List<PostComment> roots = [];
    for (final dto in dtos) {
      if (dto.parentId == null || dto.parentId!.isEmpty) {
        roots.add(buildNode(dto));
      }
    }

    if (roots.isEmpty && dtos.isNotEmpty) {
      return dtos.map(mapDto).toList();
    }

    return roots;
  }

  @override
  Future<PostComment> addComment({
    required String postId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('Comment text is required.');
    }

    try {
      final response = await _dio.post<dynamic>(
        PostsApiEndpoint.comments(postId),
        data: {'body': trimmed},
      );

      final dto = CommentApiDto.parseResponse(response.data);
      final actorIds = await CommentMapper.currentActorIds();
      return CommentMapper.toPostComment(
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
  Future<String> createTextPost(PostComposeDraft draft) async {
    try {
      final payload = await _buildTextPostPayload(draft);
      if (payload.content.trim().isEmpty) {
        throw const AuthException('Post content is required.');
      }

      final Response<dynamic> response;

      if (payload.hasMultipartPayload) {
        final formData = await payload.toFormData();
        FaithLogger.d(
          'PostRemoteDataSource',
          'Creating post with multipart payload: ${payload.toJson()}',
        );
        response = await _dio.post<dynamic>(
          PostsApiEndpoint.list,
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(minutes: 5),
            receiveTimeout: const Duration(minutes: 2),
          ),
        );
      } else {
        final jsonPayload = payload.toJson();
        FaithLogger.d(
          'PostRemoteDataSource',
          'Creating post with JSON payload: $jsonPayload',
        );
        response = await _dio.post<dynamic>(
          PostsApiEndpoint.list,
          data: jsonPayload,
        );
      }

      return ApiCreateResponse.parseId(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<CreatePostDto> _buildTextPostPayload(PostComposeDraft draft) async {
    final payload = CreatePostMapper.fromTextDraft(draft);
    final media = draft.uploadedMedia;
    if (media == null || media.kind != MediaUploadKind.video) {
      return payload;
    }

    final uploadedId = await _uploadNovaFile(media.filePath);
    return CreatePostDto(
      title: payload.title,
      content: payload.content,
      isTagged: payload.isTagged,
      novaFileIds: [uploadedId],
      filePaths: const [],
    );
  }

  @override
  Future<String> createShort(PostComposeDraft draft) async {
    try {
      final payload = CreateShortMapper.fromDraft(draft);

      final uploadResponse = await _dio.post<dynamic>(
        ShortsApiEndpoint.list,
        data: await payload.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final shortId = ApiCreateResponse.parseId(uploadResponse.data);

      await _dio.post<dynamic>(ShortsApiEndpoint.publish(shortId));

      return shortId;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<String> _uploadNovaFile(String filePath) async {
    final trimmedPath = filePath.trim();
    if (MediaUrlResolver.isNetworkImageUrl(trimmedPath) ||
        MediaUrlResolver.isVideoUrl(trimmedPath)) {
      return trimmedPath;
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(trimmedPath),
    });

    final response = await _dio.post<dynamic>(
      NovaFilesApiEndpoint.upload,
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    return ApiCreateResponse.parseId(response.data);
  }

  @override
  Future<String> publishComposeStub(PostComposeDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return 'local-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<PostLikeState> likePost(String postId) async {
    try {
      final response = await _dio.post<dynamic>(PostsApiEndpoint.like(postId));
      return PostLikeResultDto.parseResponse(
        response.data,
        liked: true,
      ).toEntity();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<PostLikeState> unlikePost(String postId) async {
    try {
      final response = await _dio.delete<dynamic>(
        PostsApiEndpoint.like(postId),
      );
      return PostLikeResultDto.parseResponse(
        response.data,
        liked: false,
      ).toEntity();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete<dynamic>(PostsApiEndpoint.detail(postId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> savePost(String postId) async {
    try {
      await _dio.post<dynamic>(PostsApiEndpoint.save(postId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> unsavePost(String postId) async {
    try {
      await _dio.delete<dynamic>(PostsApiEndpoint.save(postId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> updatePost({
    required String postId,
    required String content,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) async {
    final trimmed = content.trim();

    try {
      final form = FormData();
      form.fields.add(MapEntry('content', trimmed));

      if (newMedia != null) {
        if (newMedia.kind == MediaUploadKind.video) {
          final uploadedId = await _uploadNovaFile(newMedia.filePath);
          form.fields.add(MapEntry('novaFileIds', jsonEncode([uploadedId])));
        } else {
          if (removeExistingMedia) {
            form.fields.add(const MapEntry('novaFileIds', '[]'));
          }
          form.files.add(
            MapEntry('files', await MultipartFile.fromFile(newMedia.filePath)),
          );
        }
      } else if (removeExistingMedia) {
        form.fields.add(const MapEntry('novaFileIds', '[]'));
      }

      await _dio.patch<dynamic>(PostsApiEndpoint.detail(postId), data: form);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
