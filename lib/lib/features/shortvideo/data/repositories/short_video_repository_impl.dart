import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/shortvideo/data/datasources/short_video_remote_datasource.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflections_feed.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/shorts_query_filter.dart';
import 'package:faithconnect/features/shortvideo/domain/repositories/short_video_repository.dart';

class ShortVideoRepositoryImpl implements ShortVideoRepository {
  final ShortVideoRemoteDataSource remoteDataSource;

  ShortVideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ShortVideo>>> getShortVideos() async {
    try {
      final videos = await remoteDataSource.getShortVideos(
        filter: ShortsQueryFilter.defaults(),
      );
      return Right(videos);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReflectionsFeed>> getReflections(
    String shortVideoId,
  ) async {
    try {
      final feed = await remoteDataSource.getReflections(shortVideoId);
      return Right(feed);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reflection>> addReflection({
    required String shortVideoId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final reflection = await remoteDataSource.addReflection(
        shortVideoId: shortVideoId,
        text: text,
        parentCommentId: parentCommentId,
      );
      return Right(reflection);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReflection({
    required String shortVideoId,
    required String commentId,
  }) async {
    try {
      await remoteDataSource.deleteReflection(shortVideoId, commentId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteShort(String shortId) async {
    try {
      await remoteDataSource.deleteShort(shortId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShort({
    required String shortId,
    required String title,
  }) async {
    try {
      await remoteDataSource.updateShort(shortId: shortId, title: title);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
