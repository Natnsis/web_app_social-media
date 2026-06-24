import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/domain/repositories/discovery_repository.dart';

class DiscoveryService {
  final DiscoveryRepository _repository;

  DiscoveryService(this._repository);

  Future<Either<Failure, DiscoveryContent>> getDiscoveryContent({
    NearbyChurchesFilter nearbyFilter = const NearbyChurchesFilter(),
  }) =>
      _repository.getDiscoveryContent(nearbyFilter: nearbyFilter);

  Future<Either<Failure, NearbyChurchesResult>> getNearbyChurches({
    NearbyChurchesFilter filter = const NearbyChurchesFilter(),
  }) =>
      _repository.getNearbyChurches(filter: filter);

  Future<Either<Failure, void>> toggleFollowChurch({
    required String churchId,
    required bool follow,
  }) =>
      follow
          ? _repository.toggleFollowChurch(churchId: churchId, follow: true)
          : unfollowChurch(churchId: churchId);

  Future<Either<Failure, void>> unfollowChurch({
    required String churchId,
  }) =>
      _repository.toggleFollowChurch(churchId: churchId, follow: false);
}
