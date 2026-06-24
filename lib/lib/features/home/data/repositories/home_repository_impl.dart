import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/home/data/datasources/home_remote_datasource.dart';
import 'package:faithconnect/features/home/domain/entities/home_feed.dart';
import 'package:faithconnect/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HomeFeed>> getFeed() async {
    try {
      final feed = await remoteDataSource.getFeed();
      return Right(feed);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
