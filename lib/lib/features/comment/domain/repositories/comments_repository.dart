import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/comment/domain/entities/comment_like_state.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';

abstract class CommentsRepository {
  Future<Either<Failure, List<PostComment>>> fetchPostCommentReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  });

  Future<Either<Failure, List<Reflection>>> fetchReflectionReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  });

  Future<Either<Failure, Reflection>> replyToReflection({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  });

  Future<Either<Failure, PostComment>> replyToPostComment({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  });

  Future<Either<Failure, Reflection>> updateReflection({
    required String commentId,
    required String body,
  });

  Future<Either<Failure, PostComment>> updatePostComment({
    required String commentId,
    required String body,
  });

  Future<Either<Failure, CommentLikeState>> likeComment(String commentId);

  Future<Either<Failure, CommentLikeState>> unlikeComment(String commentId);

  Future<Either<Failure, Unit>> deleteComment(String commentId);
}
