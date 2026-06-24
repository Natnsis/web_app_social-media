import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_otp_pin_input.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet to verify phone OTP (`POST /v1/auth/otp/verify`).
class OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationSheet({super.key, required this.phoneNumber});

  static Future<void> show(
    BuildContext context, {
    required String phoneNumber,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpVerificationSheet(phoneNumber: phoneNumber),
    );
  }

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final otp = _pinController.text.trim();
    if (otp.length < 4) {
      showError(context, 'Enter the verification code');
      return;
    }
    context.read<AuthBloc>().add(
          AuthOtpVerifyRequested(
            phoneNumber: widget.phoneNumber,
            otp: otp,
          ),
        );
  }

  void _resend() {
    context.read<AuthBloc>().add(
          AuthOtpResendRequested(phoneNumber: widget.phoneNumber),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pop();
          showSuccess(context, 'Phone verified successfully');
        } else if (state is AuthOtpResent) {
          showSuccess(context, 'Verification code sent');
        } else if (state is AuthFailureState) {
          showError(context, state.message);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              decoration: BoxDecoration(
                color: auth.surfaceFill,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: auth.subtitleColor.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Verify your phone',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: auth.titleColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter the code sent to ${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: auth.subtitleColor,
                      fontSize: 14.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  AuthOtpPinInput(
                    controller: _pinController,
                    focusNode: _focusNode,
                    enabled: !isLoading,
                    onCompleted: _submit,
                  ),
                  SizedBox(height: 24.h),
                  AuthPrimaryButton(
                    label: 'Verify',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: isLoading ? null : _resend,
                    child: Text(
                      'Resend code',
                      style: GoogleFonts.inter(
                        color: colors.brandBlue,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
