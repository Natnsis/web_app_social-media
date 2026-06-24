import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/onboarding/domain/entities/onboarding_slide.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingActive extends OnboardingState {
  final List<OnboardingSlide> slides;
  final int currentIndex;

  const OnboardingActive({
    required this.slides,
    this.currentIndex = 0,
  });

  OnboardingSlide get currentSlide => slides[currentIndex];

  bool get isLastPage => currentIndex >= slides.length - 1;

  OnboardingActive copyWith({int? currentIndex}) {
    return OnboardingActive(
      slides: slides,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [slides, currentIndex];
}

final class OnboardingFinished extends OnboardingState {
  const OnboardingFinished();
}
