import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/features/onboarding/domain/onboarding_slides.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_event.dart';
import 'package:faithconnect/features/onboarding/presentation/blocs/onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingSkipPressed>(_onSkipPressed);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) {
    emit(OnboardingActive(slides: OnboardingSlides.slides));
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state;
    if (current is OnboardingActive) {
      emit(current.copyWith(currentIndex: event.index));
    }
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    final current = state;
    if (current is! OnboardingActive) return;

    if (current.isLastPage) {
      add(const OnboardingCompleted());
    } else {
      emit(current.copyWith(currentIndex: current.currentIndex + 1));
    }
  }

  Future<void> _onSkipPressed(
    OnboardingSkipPressed event,
    Emitter<OnboardingState> emit,
  ) async {
    add(const OnboardingCompleted());
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await SharedPrefsService.setFirstLaunchDone();
    emit(const OnboardingFinished());
  }
}
