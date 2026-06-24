import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/core/network/auth_token_refresh_service.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/utils/phone_normalizer.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:faithconnect/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:faithconnect/features/auth/application/google_auth_service.dart';
import 'package:faithconnect/features/auth/data/models/user_model.dart';
import 'package:faithconnect/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:faithconnect/features/auth/domain/entities/user.dart';
import 'package:faithconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';
import 'package:faithconnect/injection.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final AuthTokenRefreshService tokenRefresh;
  final GoogleAuthService googleAuthService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.tokenRefresh,
    required this.googleAuthService,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(await _completeSignIn(userModel));
    } on AuthException catch (e) {
      return Left(
        await _failureFromAuthException(
          e,
          identifierForVerification: email,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    const tag = 'AuthRepository';
    FaithLogger.i(tag, 'loginWithGoogle: start');

    try {
      final userModel = await googleAuthService.signIn();

      FaithLogger.i(tag, 'loginWithGoogle: complete userId=${userModel.id}');
      return Right(await _completeSignIn(userModel));
    } on AuthException catch (e) {
      if (e.isCancelled) {
        FaithLogger.d(tag, 'loginWithGoogle: cancelled by user');
        return const Left(AuthSignInCancelledFailure());
      }
      FaithLogger.e(tag, 'Google login failed: ${e.message}');
      return Left(
        await _failureFromAuthException(
          e,
          identifierForVerification: '',
        ),
      );
    } catch (e) {
      FaithLogger.e(tag, 'loginWithGoogle unexpected error', e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<User> _completeSignIn(UserModel userModel) async {
    await localDataSource.cacheUser(userModel);
    await _syncShellModeFromUser(userModel);
    await SharedPrefsService.clearPendingVerificationPhone();
    return userModel.toEntity();
  }

  Future<void> _syncShellModeFromUser(UserModel userModel) async {
    if (!sl.isRegistered<HomeShellModeNotifier>()) return;
    await sl<HomeShellModeNotifier>().applyUserRoles(userModel.roles);
  }

  Future<Failure> _failureFromAuthException(
    AuthException e, {
    String? identifierForVerification,
  }) async {
    if (e.isAccountNotVerified) {
      final phone = await _resolvePhoneForVerification(
        identifier: identifierForVerification ?? '',
        fromApi: e.phoneNumber,
      );
      return UnverifiedAccountFailure(
        message: e.message,
        phoneNumber: phone,
      );
    }
    return AuthFailure(message: e.message);
  }

  @override
  Future<Either<Failure, SignUpOutcome>> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signUp(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response.requiresVerification) {
        await SharedPrefsService.setPendingVerificationPhone(
          response.phoneNumber,
        );
        await SharedPrefsService.setLoggedIn(false);
        return Right(
          SignUpOutcome(
            user: response.user.toEntity(),
            requiresVerification: true,
            phoneNumber: response.phoneNumber,
          ),
        );
      }

      await localDataSource.cacheUser(response.user);
      await _syncShellModeFromUser(response.user);
      await SharedPrefsService.clearPendingVerificationPhone();
      return Right(
        SignUpOutcome(
          user: response.user.toEntity(),
          requiresVerification: false,
          phoneNumber: response.phoneNumber,
        ),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final userModel = await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      await localDataSource.cacheUser(userModel);
      await _syncShellModeFromUser(userModel);
      await SharedPrefsService.clearPendingVerificationPhone();
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phoneNumber}) async {
    try {
      await remoteDataSource.resendOtp(phoneNumber: phoneNumber);
      await SharedPrefsService.setPendingVerificationPhone(phoneNumber);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset({
    required String phoneNumber,
  }) async {
    try {
      await remoteDataSource.requestPasswordReset(phoneNumber: phoneNumber);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        phoneNumber: phoneNumber,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await googleAuthService.signOut();
      await localDataSource.clearSession();
      await SharedPrefsService.clearPendingVerificationPhone();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final pendingPhone =
          await SharedPrefsService.getPendingVerificationPhone();
      if (pendingPhone != null && pendingPhone.isNotEmpty) {
        return const Right(null);
      }

      final loggedIn = await SharedPrefsService.isLoggedIn();
      if (!loggedIn) return const Right(null);

      final access = await SharedPrefsService.getAccessToken();
      if (access == null || access.isEmpty) {
        final refreshed = await tokenRefresh.refreshAccessToken();
        if (refreshed == null || refreshed.isEmpty) {
          return const Right(null);
        }
      }

      final user = await localDataSource.getCachedUser();
      return Right(user?.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> restoreSession() async {
    try {
      final pendingPhone =
          await SharedPrefsService.getPendingVerificationPhone();
      if (pendingPhone != null && pendingPhone.isNotEmpty) {
        return const Right(false);
      }

      if (!await SharedPrefsService.isLoggedIn()) {
        return const Right(false);
      }

      final access = await SharedPrefsService.getAccessToken();
      if (access != null && access.isNotEmpty) {
        return const Right(true);
      }

      if (!await SharedPrefsService.hasRefreshToken()) {
        return const Right(false);
      }

      final newAccess = await tokenRefresh.refreshAccessToken();
      return Right(newAccess != null && newAccess.isNotEmpty);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<String> _resolvePhoneForVerification({
    required String identifier,
    String? fromApi,
  }) async {
    if (fromApi != null && fromApi.isNotEmpty) {
      return PhoneNormalizer.normalize(fromApi);
    }
    if (PhoneNormalizer.looksLikePhone(identifier)) {
      return PhoneNormalizer.normalize(identifier);
    }
    final pending = await SharedPrefsService.getPendingVerificationPhone();
    if (pending != null && pending.isNotEmpty) {
      return pending;
    }
    return PhoneNormalizer.normalize(identifier);
  }
}
