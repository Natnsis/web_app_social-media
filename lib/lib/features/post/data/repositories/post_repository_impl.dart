import 'package:dartz/dartz.dart';

import 'package:faithconnect/core/error/failures.dart';

import 'package:faithconnect/features/auth/data/auth_exception.dart';

import 'package:faithconnect/features/post/data/datasources/post_remote_datasource.dart';

import 'package:faithconnect/features/post/domain/entities/post_comment.dart';

import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';

import 'package:faithconnect/features/post/domain/entities/post_detail.dart';
import 'package:faithconnect/features/post/domain/entities/post_like_state.dart';
import 'package:faithconnect/features/post/domain/repositories/post_repository.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';



class PostRepositoryImpl implements PostRepository {

  final PostRemoteDataSource remoteDataSource;



  PostRepositoryImpl({required this.remoteDataSource});



  @override

  Future<Either<Failure, PostDetail>> getPostDetail(String postId) async {

    try {

      final detail = await remoteDataSource.getPostDetail(postId);

      return Right(detail);

    } on AuthException catch (e) {

      return Left(AuthFailure(message: e.message));

    } catch (e) {

      return Left(ServerFailure(message: e.toString()));

    }

  }



  @override

  Future<Either<Failure, PostComment>> addComment({

    required String postId,

    required String text,

  }) async {

    try {

      final comment = await remoteDataSource.addComment(

        postId: postId,

        text: text,

      );

      return Right(comment);

    } on AuthException catch (e) {

      return Left(AuthFailure(message: e.message));

    } catch (e) {

      return Left(ServerFailure(message: e.toString()));

    }

  }



  @override

  Future<Either<Failure, String>> createTextPost(PostComposeDraft draft) async {

    try {

      final id = await remoteDataSource.createTextPost(draft);

      return Right(id);

    } on AuthException catch (e) {

      return Left(AuthFailure(message: e.message));

    } catch (e) {

      return Left(ServerFailure(message: e.toString()));

    }

  }



  @override

  Future<Either<Failure, String>> createShort(PostComposeDraft draft) async {

    try {

      final id = await remoteDataSource.createShort(draft);

      return Right(id);

    } on AuthException catch (e) {

      return Left(AuthFailure(message: e.message));

    } catch (e) {

      return Left(ServerFailure(message: e.toString()));

    }

  }



  @override

  Future<Either<Failure, String>> publishComposeStub(

    PostComposeDraft draft,

  ) async {

    try {

      final id = await remoteDataSource.publishComposeStub(draft);

      return Right(id);

    } catch (e) {

      return Left(ServerFailure(message: e.toString()));

    }

  }



  @override

  Future<Either<Failure, PostLikeState>> likePost(String postId) async {

    try {

      final state = await remoteDataSource.likePost(postId);

      return Right(state);

    } on AuthException catch (e) {

      return Left(AuthFailure(message: e.message));

    } catch (e) {

      return Left(ServerFailure(message: e.toString()));

    }

  }



  @override

  Future<Either<Failure, PostLikeState>> unlikePost(String postId) async {

    try {

      final state = await remoteDataSource.unlikePost(postId);

      return Right(state);

    } on AuthException catch (e) {

      return Left(AuthFailure(message: e.message));

    } catch (e) {

      return Left(ServerFailure(message: e.toString()));

    }

  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePost(String postId) async {
    try {
      await remoteDataSource.savePost(postId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unsavePost(String postId) async {
    try {
      await remoteDataSource.unsavePost(postId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePost({
    required String postId,
    required String content,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) async {
    try {
      await remoteDataSource.updatePost(
        postId: postId,
        content: content,
        newMedia: newMedia,
        removeExistingMedia: removeExistingMedia,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

}

