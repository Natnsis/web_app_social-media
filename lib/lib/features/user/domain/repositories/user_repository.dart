import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/features/user/data/dto/update_user_profile_dto.dart';
import 'package:faithconnect/features/user/domain/entities/searched_user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<SearchedUser>>> searchUsers({
    String? query,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, User>> getCurrentUserProfile();

  Future<Either<Failure, User>> updateCurrentUserProfile(
    UpdateUserProfileDto payload,
  );
}
