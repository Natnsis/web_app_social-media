import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/post/domain/entities/post_detail.dart';
import 'package:faithconnect/features/post/domain/entities/post_like_state.dart';
import 'package:faithconnect/features/post/domain/repositories/post_repository.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';

class PostService {
  final PostRepository _repository;

  PostService(this._repository);

  Future<Either<Failure, PostDetail>> getPostDetail(String postId) =>
      _repository.getPostDetail(postId);

  Future<Either<Failure, PostComment>> addComment({
    required String postId,
    required String text,
  }) =>
      _repository.addComment(postId: postId, text: text);

  Future<Either<Failure, PostLikeState>> likePost(String postId) =>
      _repository.likePost(postId);

  Future<Either<Failure, PostLikeState>> unlikePost(String postId) =>
      _repository.unlikePost(postId);

  Future<Either<Failure, void>> deletePost(String postId) =>
      _repository.deletePost(postId);

  Future<Either<Failure, void>> savePost(String postId) =>
      _repository.savePost(postId);

  Future<Either<Failure, void>> unsavePost(String postId) =>
      _repository.unsavePost(postId);

  Future<Either<Failure, void>> updatePost({
    required String postId,
    required String content,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) =>
      _repository.updatePost(
        postId: postId,
        content: content,
        newMedia: newMedia,
        removeExistingMedia: removeExistingMedia,
      );
}
