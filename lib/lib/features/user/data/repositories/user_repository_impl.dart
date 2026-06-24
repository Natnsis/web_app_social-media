import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';
import 'package:faithconnect/features/user/data/datasources/user_remote_datasource.dart';
import 'package:faithconnect/features/user/data/dto/update_user_profile_dto.dart';
import 'package:faithconnect/features/user/data/mappers/user_mapper.dart';
import 'package:faithconnect/features/user/domain/entities/searched_user.dart';
import 'package:faithconnect/features/user/domain/repositories/user_repository.dart';
import 'package:faithconnect/injection.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required UserRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<SearchedUser>>> searchUsers({
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final dtos = await _remoteDataSource.searchUsers(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(dtos.map(UserMapper.fromSearchDto).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUserProfile() async {
    try {
      final user = await _remoteDataSource.getCurrentUserProfile();
      await SharedPrefsService.saveUser(user);
      await _syncShellModeFromUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateCurrentUserProfile(
    UpdateUserProfileDto payload,
  ) async {
    try {
      final user = await _remoteDataSource.updateCurrentUserProfile(payload);
      await SharedPrefsService.saveUser(user);
      await _syncShellModeFromUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<void> _syncShellModeFromUser(User user) async {
    if (!sl.isRegistered<HomeShellModeNotifier>()) return;
    await sl<HomeShellModeNotifier>().applyUserRoles(user.roles);
  }
}
