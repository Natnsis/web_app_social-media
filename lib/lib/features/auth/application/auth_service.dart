import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:faithconnect/features/auth/domain/entities/user.dart';
import 'package:faithconnect/features/auth/domain/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }

  Future<Either<Failure, User>> loginWithGoogle() =>
      _repository.loginWithGoogle();

  Future<Either<Failure, SignUpOutcome>> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return _repository.signUp(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) {
    return _repository.verifyOtp(phoneNumber: phoneNumber, otp: otp);
  }

  Future<Either<Failure, void>> resendOtp({required String phoneNumber}) {
    return _repository.resendOtp(phoneNumber: phoneNumber);
  }

  Future<Either<Failure, void>> requestPasswordReset({
    required String phoneNumber,
  }) {
    return _repository.requestPasswordReset(phoneNumber: phoneNumber);
  }

  Future<Either<Failure, void>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.resetPassword(
      phoneNumber: phoneNumber,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<Either<Failure, void>> logout() => _repository.logout();

  Future<Either<Failure, User?>> getCurrentUser() =>
      _repository.getCurrentUser();

  Future<Either<Failure, bool>> restoreSession() =>
      _repository.restoreSession();
}
