import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_detail.dart';
import 'package:faithconnect/features/post/domain/entities/post_like_state.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';

abstract class PostRepository {
  Future<Either<Failure, PostDetail>> getPostDetail(String postId);

  Future<Either<Failure, PostComment>> addComment({
    required String postId,
    required String text,
  });

  /// Text tab only — `POST /v1/posts`.
  Future<Either<Failure, String>> createTextPost(PostComposeDraft draft);

  /// Short tab — `POST /v1/shorts` then publish.
  Future<Either<Failure, String>> createShort(PostComposeDraft draft);

  /// Event and other compose types (separate APIs later).
  Future<Either<Failure, String>> publishComposeStub(PostComposeDraft draft);

  Future<Either<Failure, PostLikeState>> likePost(String postId);

  Future<Either<Failure, PostLikeState>> unlikePost(String postId);

  Future<Either<Failure, void>> deletePost(String postId);

  Future<Either<Failure, void>> savePost(String postId);

  Future<Either<Failure, void>> unsavePost(String postId);

  Future<Either<Failure, void>> updatePost({
    required String postId,
    required String content,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  });
}
