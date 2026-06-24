import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/church/data/datasources/church_remote_datasource.dart';
import 'package:faithconnect/features/church/data/mappers/church_member_mapper.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/data/mappers/following_church_mapper.dart';
import 'package:faithconnect/features/church/data/dto/update_church_profile_dto.dart';
import 'package:faithconnect/features/church/domain/entities/churches_list_result.dart';
import 'package:faithconnect/features/church/domain/entities/following_churches_result.dart';
import 'package:faithconnect/features/church/domain/repositories/church_repository.dart';

class ChurchRepositoryImpl implements ChurchRepository {
  final ChurchRemoteDataSource remoteDataSource;

  ChurchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChurchesListResult>> getChurches({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.fetchChurches(
        page: page,
        limit: limit,
      );
      return Right(
        ChurchesListResult(
          churches: result.churches
              .map((dto) => dto.toProfileModel().toEntity())
              .toList(),
          meta: result.meta,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChurchProfileFeed>> getChurchProfile(
    String profileId,
  ) async {
    try {
      final profile = await remoteDataSource.getChurchProfile(profileId);
      return Right(profile.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChurchProfile(
    String churchId,
    UpdateChurchProfileDto dto,
  ) async {
    try {
      await remoteDataSource.updateChurchProfile(churchId, dto);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleFollowChurch({
    required String churchId,
    required bool follow,
  }) async {
    try {
      await remoteDataSource.toggleFollowChurch(
        churchId: churchId,
        follow: follow,
      );
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unfollowChurch({
    required String churchId,
  }) async {
    try {
      await remoteDataSource.unfollowChurch(churchId: churchId);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FollowingChurchesResult>> getFollowingChurches({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.fetchFollowingChurches(
        page: page,
        limit: limit,
      );
      return Right(
        FollowingChurchesResult(
          churches: FollowingChurchMapper.toEntityList(result.churches),
          meta: result.meta,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChurchMember>>> getMyChurchMembers() async {
    try {
      final members = await remoteDataSource.fetchMyChurchMembers();
      return Right(ChurchMemberMapper.toEntityList(members));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChurchMember>> assignModerator({
    required String userId,
  }) async {
    try {
      final dto = await remoteDataSource.assignModerator(userId: userId);
      return Right(ChurchMemberMapper.toEntity(dto));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> revokeModerator({
    required String userId,
  }) async {
    try {
      await remoteDataSource.revokeModerator(userId: userId);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
