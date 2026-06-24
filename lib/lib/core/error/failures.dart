import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// User dismissed the Google account picker — not an error.
class AuthSignInCancelledFailure extends Failure {
  const AuthSignInCancelledFailure() : super(message: '');
}

class UnverifiedAccountFailure extends AuthFailure {
  final String phoneNumber;

  const UnverifiedAccountFailure({
    required super.message,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [message, phoneNumber];
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class ServiceFailure extends Failure {
  const ServiceFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure({required super.message});
}

class UnAuthenticatedFailure extends Failure {
  const UnAuthenticatedFailure({required super.message});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

class InternalFailure extends Failure {
  const InternalFailure({required super.message});
}
