import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/data/dto/update_church_profile_dto.dart';
import 'package:faithconnect/features/church/domain/entities/churches_list_result.dart';
import 'package:faithconnect/features/church/domain/entities/following_churches_result.dart';
import 'package:faithconnect/features/church/domain/repositories/church_repository.dart';

class ChurchService {
  final ChurchRepository _repository;

  ChurchService(this._repository);

  Future<Either<Failure, ChurchesListResult>> getChurches({
    int page = 1,
    int limit = 20,
  }) =>
      _repository.getChurches(page: page, limit: limit);

  Future<Either<Failure, ChurchProfileFeed>> getChurchProfile(String profileId) =>
      _repository.getChurchProfile(profileId);

  Future<Either<Failure, Unit>> updateChurchProfile(
    String churchId,
    UpdateChurchProfileDto dto,
  ) =>
      _repository.updateChurchProfile(churchId, dto);

  Future<Either<Failure, Unit>> toggleFollowChurch({
    required String churchId,
    required bool follow,
  }) =>
      _repository.toggleFollowChurch(churchId: churchId, follow: follow);

  Future<Either<Failure, Unit>> unfollowChurch({required String churchId}) =>
      _repository.unfollowChurch(churchId: churchId);

  Future<Either<Failure, FollowingChurchesResult>> getFollowingChurches({
    int page = 1,
    int limit = 20,
  }) =>
      _repository.getFollowingChurches(page: page, limit: limit);

  Future<Either<Failure, List<ChurchMember>>> getMyChurchMembers() =>
      _repository.getMyChurchMembers();

  Future<Either<Failure, ChurchMember>> assignModerator({
    required String userId,
  }) =>
      _repository.assignModerator(userId: userId);

  Future<Either<Failure, Unit>> revokeModerator({
    required String userId,
  }) =>
      _repository.revokeModerator(userId: userId);
}
