import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/services/socket/socket_services.dart';
import 'package:faithconnect/features/auth/application/auth_service.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthOtpVerifyRequested>(_onOtpVerifyRequested);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final pendingPhone = await SharedPrefsService.getPendingVerificationPhone();
    if (pendingPhone != null && pendingPhone.isNotEmpty) {
      emit(AuthPendingVerification(phoneNumber: pendingPhone));
      return;
    }

    final restored = await _authService.restoreSession();
    final sessionOk = restored.fold((_) => false, (ok) => ok);
    if (!sessionOk) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await _authService.getCurrentUser();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => user == null
          ? emit(const AuthUnauthenticated())
          : emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    FaithLogger.i('AuthBloc', 'AuthGoogleLoginRequested');
    final result = await _authService.loginWithGoogle();
    result.fold(
      (failure) {
        if (failure is AuthSignInCancelledFailure) {
          FaithLogger.d('AuthBloc', 'Google login cancelled');
          emit(const AuthUnauthenticated());
        } else if (failure is UnverifiedAccountFailure) {
          FaithLogger.w('AuthBloc', 'Google login unverified account');
          emit(
            AuthUnverifiedAccount(
              phoneNumber: failure.phoneNumber,
              message: failure.message,
            ),
          );
        } else {
          FaithLogger.e('AuthBloc', 'Google login failed: ${failure.message}');
          emit(AuthFailureState(failure.message));
          emit(const AuthUnauthenticated());
        }
      },
      (user) {
        FaithLogger.i(
          'AuthBloc',
          'Google login authenticated userId=${user.id} email=${user.email}',
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authService.login(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) {
        if (failure is UnverifiedAccountFailure) {
          emit(
            AuthUnverifiedAccount(
              phoneNumber: failure.phoneNumber,
              message: failure.message,
            ),
          );
        } else {
          emit(AuthFailureState(failure.message));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authService.signUp(
      fullName: event.fullName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (outcome) {
        if (outcome.requiresVerification) {
          emit(AuthPendingVerification(phoneNumber: outcome.phoneNumber));
        } else {
          emit(AuthAuthenticated(outcome.user));
        }
      },
    );
  }

  Future<void> _onOtpVerifyRequested(
    AuthOtpVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authService.verifyOtp(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authService.resendOtp(
      phoneNumber: event.phoneNumber,
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(AuthOtpResent(phoneNumber: event.phoneNumber)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authService.logout();
    await sl<SocketService>().disconnectAll();
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
