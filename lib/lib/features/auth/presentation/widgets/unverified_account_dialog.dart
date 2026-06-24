import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Shown when login fails because the account phone is not verified yet.
class UnverifiedAccountDialog extends StatelessWidget {
  final String phoneNumber;
  final String message;

  const UnverifiedAccountDialog({
    super.key,
    required this.phoneNumber,
    required this.message,
  });

  static void show(
    BuildContext context, {
    required String phoneNumber,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UnverifiedAccountDialog(
        phoneNumber: phoneNumber,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpResent) {
          Navigator.of(context).pop();
          if (!context.mounted) return;
          context.go(RoutesConstant.home);
        } else if (state is AuthFailureState) {
          showError(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return ConfirmationModal(
            title: 'Account not verified',
            subtitle:
                '$message\n\nWe can send a new verification code to $phoneNumber.',
            confirmText: isLoading ? 'Sending…' : 'Resend OTP',
            cancelText: 'Cancel',
            icon: Iconsax.shield_cross,
            onConfirm: () {
              if (isLoading) return;
              context.read<AuthBloc>().add(
                    AuthOtpResendRequested(phoneNumber: phoneNumber),
                  );
            },
            onCancel: () {},
          );
        },
      ),
    );
  }
}
