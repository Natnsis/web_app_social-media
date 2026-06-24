import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_bloc.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_event.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_state.dart';
import 'package:faithconnect/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';
import 'package:faithconnect/features/onboarding/presentation/widgets/onboarding_primary_button.dart';
import 'package:faithconnect/features/onboarding/presentation/widgets/onboarding_skip_button.dart';
import 'package:faithconnect/features/onboarding/presentation/widgets/onboarding_slide_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Status icons readable on bright hero photos (no dark app-bar band).
const _onboardingStatusBarStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final bloc = context.read<OnboardingBloc>();
    if (bloc.state is! OnboardingActive) {
      bloc.add(const OnboardingStarted());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage(int index) {
    if (!_pageController.hasClients) return;
    final current =
        _pageController.page?.round() ?? _pageController.initialPage;
    if (current == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) {
        if (current is OnboardingActive &&
            previous is OnboardingActive &&
            previous.currentIndex != current.currentIndex) {
          return true;
        }
        if (current is OnboardingFinished && previous is OnboardingActive) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is OnboardingActive) {
          _syncPage(state.currentIndex);
        } else if (state is OnboardingFinished) {
          context.go(RoutesConstant.login);
        }
      },
      builder: (context, state) {
        if (state is OnboardingInitial) {
          return const _OnboardingLoadingShell();
        }

        if (state is OnboardingFinished) {
          return const _OnboardingLoadingShell();
        }

        if (state is! OnboardingActive) {
          return const _OnboardingLoadingShell();
        }

        final colors = context.faithColors;
        final isDark = context.isDarkMode;
        final scaffoldColor =
            isDark ? DarkTheme.brandNavy : colors.scaffoldBackground;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _onboardingStatusBarStyle,
          child: Scaffold(
            backgroundColor: scaffoldColor,
            body: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.none,
                  itemCount: state.slides.length,
                  onPageChanged: (index) {
                    context
                        .read<OnboardingBloc>()
                        .add(OnboardingPageChanged(index));
                  },
                  itemBuilder: (context, index) {
                    return OnboardingSlideView(
                      slide: state.slides[index],
                    );
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h, right: 20.w),
                        child: OnboardingSkipButton(
                          onPressed: () => context
                              .read<OnboardingBloc>()
                              .add(const OnboardingSkipPressed()),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: ColoredBox(
                      color: scaffoldColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OnboardingPageIndicator(
                            count: state.slides.length,
                            activeIndex: state.currentIndex,
                          ),
                          SizedBox(height: 28.h),
                          Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
                            child: OnboardingPrimaryButton(
                              label: state.currentSlide.primaryButtonLabel,
                              onPressed: () => context
                                  .read<OnboardingBloc>()
                                  .add(const OnboardingNextPressed()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingLoadingShell extends StatelessWidget {
  const _OnboardingLoadingShell();

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? DarkTheme.brandNavy : colors.scaffoldBackground,
      body: Center(
        child: CircularProgressIndicator(color: colors.brandBlue),
      ),
    );
  }
}
