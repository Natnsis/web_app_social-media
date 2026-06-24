import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflections_feed.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';

abstract class ShortVideoRepository {
  Future<Either<Failure, List<ShortVideo>>> getShortVideos();

  Future<Either<Failure, ReflectionsFeed>> getReflections(String shortVideoId);

  Future<Either<Failure, Reflection>> addReflection({
    required String shortVideoId,
    required String text,
    String? parentCommentId,
  });

  Future<Either<Failure, void>> deleteReflection({
    required String shortVideoId,
    required String commentId,
  });

  Future<Either<Failure, void>> deleteShort(String shortId);

  Future<Either<Failure, void>> updateShort({
    required String shortId,
    required String title,
  });
}
