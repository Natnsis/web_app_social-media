/// Central asset paths for splash + onboarding visual branding.
abstract final class BrandingAssets {
  static const String _images = 'assets/images';
  static const String _splash = '$_images/splash';

  /// App / splash logo (church icon).
  static const String splashIcon = '$_splash/icon.png';

  /// Full splash artwork (add file when available).
  static const String splashBackground = '$_splash/splash_screen.png';

  /// Full splash artwork (add file when available).
  static const String churchprofileBackgrounddrakmode =
      '$_images/churchprofile/churchprofile.png';

  /// Alias for launcher, headers, etc.
  static const String appIcon = splashIcon;
  // daily verse backgroung

  static const String dailyverse = '$_images/daily_verse.png';

  static const String onboardingDeepenFaith =
      '$_images/onboarding/onboarding_deepen_faith.png';
  static const String onboardingWorshipAnywhere =
      '$_images/onboarding/onboarding_worship_anywhere.png';
  static const String onboardingStayConnected =
      '$_images/onboarding/onboarding_stay_connected.png';

  static const List<String> onboardingBackgrounds = [
    onboardingDeepenFaith,
    onboardingWorshipAnywhere,
    onboardingStayConnected,
  ];
}
