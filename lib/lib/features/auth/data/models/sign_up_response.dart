import 'package:faithconnect/features/auth/data/models/user_model.dart';

class SignUpResponse {
  final UserModel user;
  final bool requiresVerification;
  final String phoneNumber;

  const SignUpResponse({
    required this.user,
    required this.requiresVerification,
    required this.phoneNumber,
  });
}
