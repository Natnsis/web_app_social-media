import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_bloc.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_event.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_state.dart';
import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';
import 'package:faithconnect/features/splash/presentation/widgets/splash_branding_text.dart';
import 'package:faithconnect/features/splash/presentation/widgets/splash_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _splashDuration = Duration(milliseconds: 2500);

  bool _authCheckStarted = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
    _startSplashTimer();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _startSplashTimer() async {
    await Future.delayed(_splashDuration);
    if (!mounted || _authCheckStarted) return;
    _authCheckStarted = true;

    final isFirstLaunch = await SharedPrefsService.isFirstLaunch();
    if (!mounted) return;

    if (isFirstLaunch) {
      final onboardingBloc = context.read<OnboardingBloc>();
      onboardingBloc.add(const OnboardingStarted());
      await onboardingBloc.stream.firstWhere(
        (state) => state is OnboardingActive,
      );
      if (!mounted) return;
      context.go(RoutesConstant.onboarding);
      return;
    }

    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated || state is AuthPendingVerification) {
      context.go(RoutesConstant.home);
    } else if (state is AuthUnauthenticated) {
      context.go(RoutesConstant.login);
    }
  }

  SystemUiOverlayStyle _splashStatusBarOverlay(BuildContext context) {
    if (context.isDarkMode) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      );
    }
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.authPalette;
    final colors = context.faithColors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _splashStatusBarOverlay(context),
      child: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthState,
        child: BrandedGradientScaffold(
          gradient: auth.splashGradient,
          backgroundColor: auth.splashBackground,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SplashLogo(),
                      SizedBox(height: 32.h),
                      const SplashBrandingText(),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 48.h,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28.r,
                        height: 28.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colors.brandBlue.withValues(
                            alpha: context.isDarkMode ? 0.9 : 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
