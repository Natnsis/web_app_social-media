import 'package:equatable/equatable.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordPhoneSubmitted extends ForgotPasswordEvent {
  final String phoneNumber;

  const ForgotPasswordPhoneSubmitted({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

final class ForgotPasswordResetSubmitted extends ForgotPasswordEvent {
  final String phoneNumber;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  const ForgotPasswordResetSubmitted({
    required this.phoneNumber,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [phoneNumber, otp, newPassword, confirmPassword];
}

final class ForgotPasswordCodeResendRequested extends ForgotPasswordEvent {
  final String phoneNumber;

  const ForgotPasswordCodeResendRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
