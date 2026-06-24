import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/comment/domain/entities/comment_like_state.dart';
import 'package:faithconnect/features/comment/domain/repositories/comments_repository.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';

class CommentsService {
  final CommentsRepository _repository;

  CommentsService(this._repository);

  Future<Either<Failure, List<PostComment>>> fetchPostCommentReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  }) =>
      _repository.fetchPostCommentReplies(parentCommentId, skip: skip, take: take);

  Future<Either<Failure, List<Reflection>>> fetchReflectionReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  }) =>
      _repository.fetchReflectionReplies(parentCommentId, skip: skip, take: take);

  Future<Either<Failure, Reflection>> replyToReflection({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  }) =>
      _repository.replyToReflection(
        parentCommentId: parentCommentId,
        body: body,
        mediaPath: mediaPath,
      );

  Future<Either<Failure, PostComment>> replyToPostComment({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  }) =>
      _repository.replyToPostComment(
        parentCommentId: parentCommentId,
        body: body,
        mediaPath: mediaPath,
      );

  Future<Either<Failure, Reflection>> updateReflection({
    required String commentId,
    required String body,
  }) =>
      _repository.updateReflection(
        commentId: commentId,
        body: body,
      );

  Future<Either<Failure, PostComment>> updatePostComment({
    required String commentId,
    required String body,
  }) =>
      _repository.updatePostComment(
        commentId: commentId,
        body: body,
      );

  Future<Either<Failure, CommentLikeState>> likeComment(String commentId) =>
      _repository.likeComment(commentId);

  Future<Either<Failure, CommentLikeState>> unlikeComment(String commentId) =>
      _repository.unlikeComment(commentId);

  Future<Either<Failure, Unit>> deleteComment(String commentId) =>
      _repository.deleteComment(commentId);
}
