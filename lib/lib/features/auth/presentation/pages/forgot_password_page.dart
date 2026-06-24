import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/blocs/forgot_password_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/forgot_password_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/forgot_password_state.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_background.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_language_icon_button.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_otp_pin_input.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:faithconnect/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Forgot / reset password — same auth shell as [LoginPage] and [SignUpPage].
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpFocusNode = FocusNode();
  PasswordStrength _passwordStrength = PasswordStrength.empty;
  String? _verifiedPhone;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordStrength =
          evaluatePasswordStrength(_newPasswordController.text);
    });
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onPasswordChanged);
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  bool get _isResetStep => _verifiedPhone != null;

  void _submitPhone() {
    if (!(_phoneFormKey.currentState?.validate() ?? false)) return;
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordPhoneSubmitted(
            phoneNumber: _phoneController.text.trim(),
          ),
        );
  }

  void _submitReset() {
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      showError(context, 'Enter the verification code');
      return;
    }
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordResetSubmitted(
            phoneNumber: _verifiedPhone!,
            otp: otp,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          ),
        );
  }

  void _resendCode() {
    final phone = _verifiedPhone;
    if (phone == null) return;
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordCodeResendRequested(phoneNumber: phone),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordOtpSent) {
                setState(() => _verifiedPhone = state.phoneNumber);
                showSuccess(
                  context,
                  'Verification code sent to ${state.phoneNumber}',
                );
              } else if (state is ForgotPasswordResetSuccess) {
                showSuccess(context, 'Password reset successfully');
                context.go(RoutesConstant.login);
              } else if (state is ForgotPasswordFailure) {
                showError(context, state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;
              final auth = context.authPalette;
              final colors = context.faithColors;

              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: AuthGlassCard(
                        child: _isResetStep
                            ? _buildResetStep(
                                context,
                                auth,
                                colors,
                                isLoading,
                              )
                            : _buildPhoneStep(context, auth, colors, isLoading),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.topRight,
                    child: AuthLanguageIconButton(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep(
    BuildContext context,
    AuthPalette auth,
    FaithAppColors colors,
    bool isLoading,
  ) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Forgot Password',
            style: GoogleFonts.inter(
              color: auth.titleColor,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter your registered phone number to receive a reset code',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: auth.subtitleColor,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),
          AuthTextField(
            controller: _phoneController,
            hint: 'Phone number',
            keyboardType: TextInputType.phone,
            validator: AuthFormValidators.phoneNumber,
          ),
          SizedBox(height: 22.h),
          AuthPrimaryButton(
            label: 'Send code',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submitPhone,
          ),
          SizedBox(height: 24.h),
          AuthFooterLink(
            prefix: 'Remember your password?',
            actionLabel: 'Sign In',
            onActionTap: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep(
    BuildContext context,
    AuthPalette auth,
    FaithAppColors colors,
    bool isLoading,
  ) {
    return Form(
      key: _resetFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reset Password',
            style: GoogleFonts.inter(
              color: auth.titleColor,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Enter the code sent to $_verifiedPhone and your new password',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: auth.subtitleColor,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),
          AuthOtpPinInput(
            controller: _otpController,
            focusNode: _otpFocusNode,
            enabled: !isLoading,
          ),
          SizedBox(height: 14.h),
          AuthTextField(
            controller: _newPasswordController,
            hint: 'New password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 10.h),
          PasswordStrengthIndicator(strength: _passwordStrength),
          SizedBox(height: 14.h),
          AuthTextField(
            controller: _confirmPasswordController,
            hint: 'Confirm password',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirm your password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => setState(() => _verifiedPhone = null),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change number',
                  style: GoogleFonts.inter(
                    color: colors.brandBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: isLoading ? null : _resendCode,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Resend code',
                  style: GoogleFonts.inter(
                    color: colors.brandBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          AuthPrimaryButton(
            label: 'Reset password',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submitReset,
          ),
          SizedBox(height: 24.h),
          AuthFooterLink(
            prefix: 'Remember your password?',
            actionLabel: 'Sign In',
            onActionTap: () => context.go(RoutesConstant.login),
          ),
        ],
      ),
    );
  }
}
