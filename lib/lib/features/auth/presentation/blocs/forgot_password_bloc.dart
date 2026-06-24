import 'package:faithconnect/core/utils/phone_normalizer.dart';
import 'package:faithconnect/features/auth/application/auth_service.dart';
import 'package:faithconnect/features/auth/presentation/blocs/forgot_password_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/forgot_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthService _authService;

  ForgotPasswordBloc({required AuthService authService})
      : _authService = authService,
        super(const ForgotPasswordInitial()) {
    on<ForgotPasswordPhoneSubmitted>(_onPhoneSubmitted);
    on<ForgotPasswordResetSubmitted>(_onResetSubmitted);
    on<ForgotPasswordCodeResendRequested>(_onCodeResendRequested);
  }

  Future<void> _onPhoneSubmitted(
    ForgotPasswordPhoneSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _authService.requestPasswordReset(
      phoneNumber: event.phoneNumber,
    );
    result.fold(
      (failure) => emit(ForgotPasswordFailure(failure.message)),
      (_) => emit(
        ForgotPasswordOtpSent(
          phoneNumber: PhoneNormalizer.normalize(event.phoneNumber),
        ),
      ),
    );
  }

  Future<void> _onResetSubmitted(
    ForgotPasswordResetSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _authService.resetPassword(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );
    result.fold(
      (failure) => emit(ForgotPasswordFailure(failure.message)),
      (_) => emit(const ForgotPasswordResetSuccess()),
    );
  }

  Future<void> _onCodeResendRequested(
    ForgotPasswordCodeResendRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    final result = await _authService.requestPasswordReset(
      phoneNumber: event.phoneNumber,
    );
    result.fold(
      (failure) => emit(ForgotPasswordFailure(failure.message)),
      (_) => emit(
        ForgotPasswordOtpSent(
          phoneNumber: PhoneNormalizer.normalize(event.phoneNumber),
        ),
      ),
    );
  }
}
