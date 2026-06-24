import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_background.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_language_icon_button.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:faithconnect/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:faithconnect/features/auth/presentation/widgets/pending_otp_verification_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  PasswordStrength _passwordStrength = PasswordStrength.empty;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordStrength = evaluatePasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthSignUpRequested(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return PendingOtpVerificationHost(
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go(RoutesConstant.home);
              } else if (state is AuthFailureState) {
                showError(context, state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              final auth = context.authPalette;

              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: AuthGlassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sign Up',
                                style: GoogleFonts.inter(
                                  color: auth.titleColor,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Create an account to continue!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: auth.subtitleColor,
                                  fontSize: 14.sp,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 28.h),
                              AuthTextField(
                                controller: _fullNameController,
                                hint: 'Full name',
                                validator: AuthFormValidators.fullName,
                              ),
                              SizedBox(height: 14.h),
                              AuthTextField(
                                controller: _emailController,
                                hint: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                validator: AuthFormValidators.email,
                              ),
                              SizedBox(height: 14.h),
                              AuthTextField(
                                controller: _phoneController,
                                hint: 'Phone number',
                                keyboardType: TextInputType.phone,
                                validator: AuthFormValidators.phoneNumber,
                              ),
                              SizedBox(height: 14.h),
                              AuthTextField(
                                controller: _passwordController,
                                hint: 'Password',
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
                              PasswordStrengthIndicator(
                                strength: _passwordStrength,
                              ),
                              SizedBox(height: 22.h),
                              AuthPrimaryButton(
                                label: 'Sign Up',
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _submit,
                              ),
                              SizedBox(height: 24.h),
                              AuthFooterLink(
                                prefix: 'Already have an account?',
                                actionLabel: 'Login',
                                onActionTap: () => context.pop(),
                              ),
                            ],
                          ),
                        ),
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
      ),
    );
  }
}
