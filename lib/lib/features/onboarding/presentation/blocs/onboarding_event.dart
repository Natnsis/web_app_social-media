import 'package:equatable/equatable.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

final class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

final class OnboardingPageChanged extends OnboardingEvent {
  final int index;

  const OnboardingPageChanged(this.index);

  @override
  List<Object?> get props => [index];
}

final class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

final class OnboardingSkipPressed extends OnboardingEvent {
  const OnboardingSkipPressed();
}

final class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
