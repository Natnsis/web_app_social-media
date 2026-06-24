import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/discovery/data/datasources/discovery_remote_datasource.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DiscoveryContent>> getDiscoveryContent({
    NearbyChurchesFilter nearbyFilter = const NearbyChurchesFilter(),
  }) async {
    try {
      return Right(
        await remoteDataSource.fetchDiscoveryContent(
          nearbyFilter: nearbyFilter,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: _messageFrom(e)));
    }
  }

  @override
  Future<Either<Failure, NearbyChurchesResult>> getNearbyChurches({
    NearbyChurchesFilter filter = const NearbyChurchesFilter(),
  }) async {
    try {
      return Right(
        await remoteDataSource.fetchNearbyChurches(filter: filter),
      );
    } catch (e) {
      return Left(ServerFailure(message: _messageFrom(e)));
    }
  }

  String _messageFrom(Object error) {
    if (error is AuthException) return error.message;
    return error.toString();
  }

  @override
  Future<Either<Failure, void>> toggleFollowChurch({
    required String churchId,
    required bool follow,
  }) async {
    try {
      await remoteDataSource.toggleFollowChurch(
        churchId: churchId,
        follow: follow,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: _messageFrom(e)));
    }
  }
}
