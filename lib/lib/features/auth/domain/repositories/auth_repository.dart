import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:faithconnect/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Google SDK → `POST /v1/auth/login/google` with `{ "idToken": "..." }`.
  Future<Either<Failure, User>> loginWithGoogle();

  Future<Either<Failure, SignUpOutcome>> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<Either<Failure, void>> resendOtp({required String phoneNumber});

  Future<Either<Failure, void>> requestPasswordReset({
    required String phoneNumber,
  });

  Future<Either<Failure, void>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  /// Refreshes access token when missing but refresh token exists.
  Future<Either<Failure, bool>> restoreSession();
}
