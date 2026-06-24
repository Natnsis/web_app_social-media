import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/home/domain/entities/home_feed.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeFeed>> getFeed();
}
