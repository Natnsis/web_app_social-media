import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/comment/data/datasources/comments_remote_datasource.dart';
import 'package:faithconnect/features/comment/data/mappers/comment_mapper.dart';
import 'package:faithconnect/features/comment/domain/entities/comment_like_state.dart';
import 'package:faithconnect/features/comment/domain/repositories/comments_repository.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  CommentsRepositoryImpl({required CommentsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final CommentsRemoteDataSource _remoteDataSource;

  Future<({String? userId, String? churchId})> _actorIds() =>
      CommentMapper.currentActorIds();

  @override
  Future<Either<Failure, List<PostComment>>> fetchPostCommentReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  }) async {
    try {
      final dtos = await _remoteDataSource.fetchCommentReplies(
        parentCommentId,
        skip: skip,
        take: take,
      );
      final actorIds = await _actorIds();
      return Right(
        dtos
            .map(
              (dto) => CommentMapper.toPostComment(
                dto,
                currentUserId: actorIds.userId,
                currentChurchId: actorIds.churchId,
              ),
            )
            .toList(),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reflection>>> fetchReflectionReplies(
    String parentCommentId, {
    int skip = 0,
    int take = 30,
  }) async {
    try {
      final dtos = await _remoteDataSource.fetchCommentReplies(
        parentCommentId,
        skip: skip,
        take: take,
      );
      final actorIds = await _actorIds();
      // Build a proper sub-tree so nested replies appear at the right depth
      // instead of being flattened as sibling children of the parent node.
      return Right(
        CommentMapper.buildReflectionTree(
          dtos,
          currentUserId: actorIds.userId,
          currentChurchId: actorIds.churchId,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reflection>> replyToReflection({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  }) async {
    try {
      final dto = await _remoteDataSource.replyToComment(
        parentCommentId: parentCommentId,
        body: body,
        mediaPath: mediaPath,
      );
      final actorIds = await _actorIds();
      return Right(
        CommentMapper.toReflection(
          dto,
          currentUserId: actorIds.userId,
          currentChurchId: actorIds.churchId,
        ).copyWith(isOwnedByMe: true),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostComment>> replyToPostComment({
    required String parentCommentId,
    required String body,
    String? mediaPath,
  }) async {
    try {
      final dto = await _remoteDataSource.replyToComment(
        parentCommentId: parentCommentId,
        body: body,
        mediaPath: mediaPath,
      );
      final actorIds = await _actorIds();
      return Right(
        CommentMapper.toPostComment(
          dto,
          currentUserId: actorIds.userId,
          currentChurchId: actorIds.churchId,
        ).copyWith(isOwnedByMe: true),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reflection>> updateReflection({
    required String commentId,
    required String body,
  }) async {
    try {
      final dto = await _remoteDataSource.updateComment(
        commentId: commentId,
        body: body,
      );
      final actorIds = await _actorIds();
      return Right(
        CommentMapper.toReflection(
          dto,
          currentUserId: actorIds.userId,
          currentChurchId: actorIds.churchId,
        ).copyWith(isOwnedByMe: true),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostComment>> updatePostComment({
    required String commentId,
    required String body,
  }) async {
    try {
      final dto = await _remoteDataSource.updateComment(
        commentId: commentId,
        body: body,
      );
      final actorIds = await _actorIds();
      return Right(
        CommentMapper.toPostComment(
          dto,
          currentUserId: actorIds.userId,
          currentChurchId: actorIds.churchId,
        ).copyWith(isOwnedByMe: true),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentLikeState>> likeComment(
    String commentId,
  ) async {
    try {
      final result = await _remoteDataSource.likeComment(commentId);
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommentLikeState>> unlikeComment(
    String commentId,
  ) async {
    try {
      final result = await _remoteDataSource.unlikeComment(commentId);
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteComment(String commentId) async {
    try {
      await _remoteDataSource.deleteComment(commentId);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
