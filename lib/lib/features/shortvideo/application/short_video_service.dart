import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflections_feed.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';
import 'package:faithconnect/features/shortvideo/domain/repositories/short_video_repository.dart';

class ShortVideoService {
  final ShortVideoRepository _repository;

  ShortVideoService(this._repository);

  Future<Either<Failure, List<ShortVideo>>> getShortVideos() =>
      _repository.getShortVideos();

  Future<Either<Failure, ReflectionsFeed>> getReflections(String shortVideoId) =>
      _repository.getReflections(shortVideoId);

  Future<Either<Failure, Reflection>> addReflection({
    required String shortVideoId,
    required String text,
    String? parentCommentId,
  }) =>
      _repository.addReflection(
        shortVideoId: shortVideoId,
        text: text,
        parentCommentId: parentCommentId,
      );

  Future<Either<Failure, void>> deleteReflection({
    required String shortVideoId,
    required String commentId,
  }) =>
      _repository.deleteReflection(
        shortVideoId: shortVideoId,
        commentId: commentId,
      );

  Future<Either<Failure, void>> deleteShort(String shortId) =>
      _repository.deleteShort(shortId);

  Future<Either<Failure, void>> updateShort({
    required String shortId,
    required String title,
  }) =>
      _repository.updateShort(shortId: shortId, title: title);
}
