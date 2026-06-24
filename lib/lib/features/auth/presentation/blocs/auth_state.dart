import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/auth/domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// After sign-up or when opening home with a stored pending phone.
final class AuthPendingVerification extends AuthState {
  final String phoneNumber;

  const AuthPendingVerification({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// Login blocked until phone OTP is verified.
final class AuthUnverifiedAccount extends AuthState {
  final String phoneNumber;
  final String message;

  const AuthUnverifiedAccount({
    required this.phoneNumber,
    required this.message,
  });

  @override
  List<Object?> get props => [phoneNumber, message];
}

final class AuthOtpResent extends AuthState {
  final String phoneNumber;

  const AuthOtpResent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

final class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
