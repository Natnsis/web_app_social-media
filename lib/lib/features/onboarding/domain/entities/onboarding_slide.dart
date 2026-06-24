import 'package:equatable/equatable.dart';

class OnboardingSlide extends Equatable {
  final String title;
  final String description;
  final String backgroundAsset;
  final String primaryButtonLabel;
  final String? footerLabel;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.backgroundAsset,
    required this.primaryButtonLabel,
    this.footerLabel,
  });

  bool get isLastSlide => footerLabel != null;

  @override
  List<Object?> get props => [
        title,
        description,
        backgroundAsset,
        primaryButtonLabel,
        footerLabel,
      ];
}
