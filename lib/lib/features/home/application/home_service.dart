import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/home/domain/entities/home_feed.dart';
import 'package:faithconnect/features/home/domain/repositories/home_repository.dart';

class HomeService {
  final HomeRepository _repository;

  HomeService(this._repository);

  Future<Either<Failure, HomeFeed>> getFeed() => _repository.getFeed();
}
