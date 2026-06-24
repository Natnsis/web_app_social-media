import 'package:faithconnect/core/constants/branding_assets.dart';
import 'package:faithconnect/features/onboarding/domain/entities/onboarding_slide.dart';

class OnboardingSlides {
  OnboardingSlides._();

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: 'Deepen Your Faith.',
      description:
          'Access timeless wisdom from past sermons and engage in meaningful spiritual discussions with your church family.',
      backgroundAsset: BrandingAssets.onboardingDeepenFaith,
      primaryButtonLabel: 'Next',
    ),
    OnboardingSlide(
      title: 'Worship Anywhere.',
      description:
          'Connect with your faith through bite-sized spiritual clips, uplifting testimonies, and worship moments that fit into your busy life.',
      backgroundAsset: BrandingAssets.onboardingWorshipAnywhere,
      primaryButtonLabel: 'Next',
    ),
    OnboardingSlide(
      title: 'Stay Connected.',
      description:
          'Experience high-quality church services live from wherever you are. Never miss a moment of worship.',
      backgroundAsset: BrandingAssets.onboardingStayConnected,
      primaryButtonLabel: 'Begin Journey',
      footerLabel: 'JOIN OVER 10,000 BELIEVERS IN ETHIOPIA',
    ),
  ];
}
