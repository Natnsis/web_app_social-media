import 'package:faithconnect/features/auth/domain/entities/user.dart';

class SignUpOutcome {
  final User user;
  final bool requiresVerification;
  final String phoneNumber;

  const SignUpOutcome({
    required this.user,
    required this.requiresVerification,
    required this.phoneNumber,
  });
}
