import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_background.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_language_icon_button.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_google_sign_in_section.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:faithconnect/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:faithconnect/features/auth/presentation/widgets/unverified_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _persistCredentialsOnAuth = false;

  @override
  void initState() {
    super.initState();
    _emailController.clear();
    _passwordController.clear();
    _initCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initCredentials() async {
    await SharedPrefsService.clearLegacyDemoLoginCredentials();
    await _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final rememberMe = await SharedPrefsService.isRememberMeEnabled();
    if (!rememberMe) {
      if (mounted) {
        setState(() {
          _rememberMe = false;
          _emailController.clear();
          _passwordController.clear();
        });
      }
      return;
    }

    final savedEmail = await SharedPrefsService.getSavedEmail();
    final savedPassword = await FlutterSecureService.getSavedPassword();
    if (!mounted) return;

    setState(() {
      _rememberMe = true;
      _emailController.text = savedEmail ?? '';
      _passwordController.text = savedPassword ?? '';
    });
  }

  Future<void> _persistLoginState() async {
    await SharedPrefsService.saveLoginCredentials(
      email: _emailController.text.trim(),
      rememberMe: _rememberMe,
    );
    if (_rememberMe) {
      await FlutterSecureService.savePassword(_passwordController.text);
    } else {
      await FlutterSecureService.deleteSavedPassword();
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _persistCredentialsOnAuth = true;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _signInWithGoogle() {
    _persistCredentialsOnAuth = false;
    FaithLogger.i('LoginPage', 'Google sign-in button tapped');
    context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthAuthenticated) {
                if (_persistCredentialsOnAuth) {
                  await _persistLoginState();
                }
                if (!context.mounted) return;
                context.go(RoutesConstant.home);
              } else if (state is AuthUnverifiedAccount) {
                UnverifiedAccountDialog.show(
                  context,
                  phoneNumber: state.phoneNumber,
                  message: state.message,
                );
              } else if (state is AuthFailureState &&
                  state.message.trim().isNotEmpty) {
                showError(context, state.message);
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Login',
                                style: GoogleFonts.inter(
                                  color: auth.titleColor,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Enter your email and password to log in',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: auth.subtitleColor,
                                  fontSize: 14.sp,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 28.h),
                              AuthTextField(
                                controller: _emailController,
                                hint: 'Email or phone',
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [],
                                validator: AuthFormValidators.emailOrPhone,
                              ),
                              SizedBox(height: 14.h),
                              AuthTextField(
                                controller: _passwordController,
                                hint: 'Password',
                                obscureText: true,
                                autofillHints: const [],
                                validator: AuthFormValidators.requiredPassword,
                              ),
                              SizedBox(height: 14.h),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) {
                                        final checked = v ?? false;
                                        setState(() => _rememberMe = checked);
                                        if (!checked) {
                                          SharedPrefsService
                                              .clearSavedLoginCredentials();
                                        }
                                      },
                                      activeColor: colors.brandBlue,
                                      side: BorderSide(
                                        color: auth.checkboxBorder,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Remember me',
                                    style: GoogleFonts.inter(
                                      color: auth.subtitleColor,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => context.pushNamed(
                                              RoutesConstant.forgotPassword,
                                            ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
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
                                label: 'Sign In',
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _submit,
                              ),
                              AuthGoogleSignInSection(
                                isLoading: isLoading,
                                onGoogleSignIn: _signInWithGoogle,
                              ),
                              SizedBox(height: 24.h),
                              AuthFooterLink(
                                prefix: "Don't have an account?",
                                actionLabel: 'Sign Up',
                                onActionTap: () =>
                                    context.push(RoutesConstant.signUp),
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
    );
  }
}
