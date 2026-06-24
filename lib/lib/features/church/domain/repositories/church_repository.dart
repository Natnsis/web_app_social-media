import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/domain/entities/churches_list_result.dart';
import 'package:faithconnect/features/church/data/dto/update_church_profile_dto.dart';
import 'package:faithconnect/features/church/domain/entities/following_churches_result.dart';

abstract class ChurchRepository {
  Future<Either<Failure, ChurchesListResult>> getChurches({
    int page,
    int limit,
  });

  Future<Either<Failure, ChurchProfileFeed>> getChurchProfile(String profileId);

  Future<Either<Failure, Unit>> updateChurchProfile(
    String churchId,
    UpdateChurchProfileDto dto,
  );

  Future<Either<Failure, Unit>> toggleFollowChurch({
    required String churchId,
    required bool follow,
  });

  Future<Either<Failure, Unit>> unfollowChurch({required String churchId});

  Future<Either<Failure, FollowingChurchesResult>> getFollowingChurches({
    int page,
    int limit,
  });

  Future<Either<Failure, List<ChurchMember>>> getMyChurchMembers();

  Future<Either<Failure, ChurchMember>> assignModerator({
    required String userId,
  });

  Future<Either<Failure, Unit>> revokeModerator({
    required String userId,
  });
}