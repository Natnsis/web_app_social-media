import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, DiscoveryContent>> getDiscoveryContent({
    NearbyChurchesFilter nearbyFilter,
  });

  Future<Either<Failure, NearbyChurchesResult>> getNearbyChurches({
    NearbyChurchesFilter filter,
  });

  Future<Either<Failure, void>> toggleFollowChurch({
    required String churchId,
    required bool follow,
  });
}
