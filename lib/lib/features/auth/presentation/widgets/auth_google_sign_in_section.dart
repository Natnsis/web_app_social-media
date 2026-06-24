import 'package:faithconnect/features/auth/presentation/widgets/auth_google_sign_in_button.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_or_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Or continue with" divider and Google sign-in on the login screen.
class AuthGoogleSignInSection extends StatelessWidget {
  final VoidCallback? onGoogleSignIn;
  final bool isLoading;

  const AuthGoogleSignInSection({
    super.key,
    this.onGoogleSignIn,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h),
        const AuthOrDivider(label: 'Or continue with'),
        SizedBox(height: 16.h),
        AuthGoogleSignInButton(
          onPressed: isLoading ? null : onGoogleSignIn,
        ),
      ],
    );
  }
}
