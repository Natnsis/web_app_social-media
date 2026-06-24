import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/features/user/data/dto/update_user_profile_dto.dart';
import 'package:faithconnect/features/user/domain/entities/searched_user.dart';
import 'package:faithconnect/features/user/domain/repositories/user_repository.dart';

class UserService {
  final UserRepository _repository;

  UserService(this._repository);

  Future<Either<Failure, List<SearchedUser>>> searchUsers({
    String? query,
    int page = 1,
    int limit = 20,
  }) =>
      _repository.searchUsers(query: query, page: page, limit: limit);

  Future<Either<Failure, User>> getCurrentUserProfile() =>
      _repository.getCurrentUserProfile();

  Future<Either<Failure, User>> updateCurrentUserProfile(
    UpdateUserProfileDto payload,
  ) =>
      _repository.updateCurrentUserProfile(payload);
}
