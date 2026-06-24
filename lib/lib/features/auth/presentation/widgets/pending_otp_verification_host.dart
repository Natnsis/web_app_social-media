import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/features/auth/presentation/widgets/otp_verification_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows OTP verification on [HomePage] when sign-up or resend left a pending phone.
class PendingOtpVerificationHost extends StatefulWidget {
  final Widget child;

  const PendingOtpVerificationHost({super.key, required this.child});

  @override
  State<PendingOtpVerificationHost> createState() =>
      _PendingOtpVerificationHostState();
}

class _PendingOtpVerificationHostState extends State<PendingOtpVerificationHost> {
  bool _sheetShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFromPrefs());
  }

  Future<void> _openFromPrefs() async {
    if (!mounted || _sheetShown) return;
    final phone = await SharedPrefsService.getPendingVerificationPhone();
    if (phone == null || phone.isEmpty || !mounted) return;
    _presentSheet(phone);
  }

  void _presentSheet(String phone) {
    if (_sheetShown || !mounted) return;
    _sheetShown = true;
    OtpVerificationSheet.show(context, phoneNumber: phone).whenComplete(() {
      if (mounted) _sheetShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPendingVerification) {
          _presentSheet(state.phoneNumber);
        } else if (state is AuthOtpResent) {
          _presentSheet(state.phoneNumber);
        } else if (state is AuthAuthenticated) {
          _sheetShown = false;
        }
      },
      child: widget.child,
    );
  }
}
