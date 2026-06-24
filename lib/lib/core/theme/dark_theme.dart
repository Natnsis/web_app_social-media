import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faithconnect/core/theme/faith_app_colors.dart';
import 'color_scheme_extensions.dart';

/// Design tokens and [ThemeData] for the dark FaithConnect UI.
abstract final class DarkTheme {
  DarkTheme._();

  // --- Primary ---
  static const Color primary50 = Color(0xFFFFFFFF);
  static const Color primary100 = Color(0xFFD4EDFD);
  static const Color primary200 = Color(0xFFA9DCFB);
  static const Color primary300 = Color(0xFF87CEFA);
  static const Color primary400 = Color(0xFF53B9F8);
  static const Color primary500 = Color(0xFF28A7F6);
  static const Color primary600 = Color(0xFF0A92E7);
  static const Color primary700 = Color(0xFF0877BC);
  static const Color primary800 = Color(0xFF065C91);
  static const Color primary900 = Color(0xFF044066);
  static const Color primary950 = Color(0xFF02253B);

  // --- Secondary ---
  static const Color secondary50 = Color(0xFFF2F4F6);
  static const Color secondary100 = Color(0xFFDADFE5);
  static const Color secondary200 = Color(0xFFC0CAD4);
  static const Color secondary300 = Color(0xFFA7B5C2);
  static const Color secondary400 = Color(0xFF8E9FB1);
  static const Color secondary500 = Color(0xFF748A9F);
  static const Color secondary600 = Color(0xFF5F7489);
  static const Color secondary700 = Color(0xFF4E5F70);
  static const Color secondary800 = Color(0xFF3C4957);
  static const Color secondary900 = Color(0xFF2B343D);
  static const Color secondary950 = Color(0xFF191F24);

  // --- Grey ---
  static const Color grey50 = Color(0xFFFAFBFC);
  static const Color grey100 = Color(0xFFF8F9FB);
  static const Color grey200 = Color(0xFFF9F9F9);
  static const Color grey300 = Color(0xFFF7F7F8);
  static const Color grey400 = Color(0xFFF5F5F5);
  static const Color grey500 = Color(0xFFEFEFF1);
  static const Color grey600 = Color(0xFFEAEBF0);
  static const Color grey700 = Color(0xFFE5E5E7);
  static const Color grey800 = Color(0xFFC1C3C7);
  static const Color grey900 = Color(0xFFA1A4AC);
  static const Color grey950 = Color(0xFF9599A1);

  // --- Accent ---
  static const Color accent50 = Color(0xFFF5F3FF);
  static const Color accent100 = Color(0xFFEDE9FE);
  static const Color accent200 = Color(0xFFDDD6FE);
  static const Color accent300 = Color(0xFFC4B5FD);
  static const Color accent400 = Color(0xFFA78BFA);
  static const Color accent500 = Color(0xFF8B5CF6);
  static const Color accent600 = Color(0xFF7C3AED);
  static const Color accent700 = Color(0xFF6D28D9);
  static const Color accent800 = Color(0xFF5B21B6);
  static const Color accent900 = Color(0xFF4C1D95);
  static const Color accent950 = Color(0xFF2E1065);

  // --- Success ---
  static const Color greenSuccess50 = Color(0xFFF0FDF4);
  static const Color greenSuccess100 = Color(0xFFDCFCE7);
  static const Color greenSuccess200 = Color(0xFFBBF7D0);
  static const Color greenSuccess300 = Color(0xFF86EFAC);
  static const Color greenSuccess400 = Color(0xFF4ADE80);
  static const Color greenSuccess500 = Color(0xFF22C55E);
  static const Color greenSuccess600 = Color(0xFF43B75D);
  static const Color greenSuccess700 = Color(0xFF15803D);
  static const Color greenSuccess800 = Color(0xFF166534);
  static const Color greenSuccess900 = Color(0xFF14532D);
  static const Color greenSuccess950 = Color(0xFF052E16);

  // --- Error ---
  static const Color redDanger50 = Color(0xFFFEF2F2);
  static const Color redDanger100 = Color(0xFFFEE2E2);
  static const Color redDanger200 = Color(0xFFFECACA);
  static const Color redDanger300 = Color(0xFFFCA5A5);
  static const Color redDanger400 = Color(0xFFF87171);
  static const Color redDanger500 = Color(0xFFEF4444);
  static const Color redDanger600 = Color(0xFFDC2626);
  static const Color redDanger700 = Color(0xFFB91C1C);
  static const Color redDanger800 = Color(0xFF991B1B);
  static const Color redDanger900 = Color(0xFF7F1D1D);
  static const Color redDanger950 = Color(0xFF450A0A);

  // --- Warning ---
  static const Color yellowWarning50 = Color(0xFFFFFBEB);
  static const Color yellowWarning100 = Color(0xFFFEF3C7);
  static const Color yellowWarning200 = Color(0xFFFDE68A);
  static const Color yellowWarning300 = Color(0xFFFCD34D);
  static const Color yellowWarning400 = Color(0xFFFBBF24);
  static const Color yellowWarning500 = Color(0xFFF59E0B);
  static const Color yellowWarning600 = Color(0xFFE99B00);
  static const Color yellowWarning700 = Color(0xFFB45309);
  static const Color yellowWarning800 = Color(0xFF92400E);
  static const Color yellowWarning900 = Color(0xFF78350F);
  static const Color yellowWarning950 = Color(0xFF451A03);

  // --- Info ---
  static const Color blueInfo50 = Color(0xFFEFF6FF);
  static const Color blueInfo100 = Color(0xFFDBEAFE);
  static const Color blueInfo200 = Color(0xFFBFDBFE);
  static const Color blueInfo300 = Color(0xFF93C5FD);
  static const Color blueInfo400 = Color(0xFF60A5FA);
  static const Color blueInfo500 = Color(0xFF3B82F6);
  static const Color blueInfo600 = Color(0xFF0095FF);
  static const Color blueInfo700 = Color(0xFF0877BC);
  static const Color blueInfo800 = Color(0xFF065C91);
  static const Color blueInfo900 = Color(0xFF044066);
  static const Color blueInfo950 = Color(0xFF02253B);

  // --- Brand / splash / onboarding ---
  static const Color brandBlue = Color(0xFF0096FF);
  static const Color brandNavy = Color(0xFF001A2C);
  static const Color brandSky = Color(0xFF33B5FF);
  static const Color descriptionText = Color(0xFFB8C4CE);
  static const Color footerMuted = Color(0xFF4A6B8A);
  static const Color skipBorder = Color(0x66FFFFFF);
  static const Color onboardingDotInactive = Color(0x99FFFFFF);
  static const Color splashDotActive = Color(0xFFB8D4F0);
  static const Color splashDotInactive = Color(0xFF2A4A6B);

  static const LinearGradient brandingFallbackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF001428), Color(0xFF0C4A7A), Color(0xFF001428)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient brandingImageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x33001A2C),
      Color(0x99001A2C),
      brandNavy,
    ],
    stops: [0.0, 0.4, 0.62, 1.0],
  );

  // --- Auth ---
  static const Color authBackgroundTop = Color(0xFF001428);
  static const Color authBackgroundBottom = Color(0xFF0C4A7A);
  static const Color authSubtitle = Color(0xFFB8C4CE);
  static const Color authFieldFill = Color(0xFF0D1F33);
  static const Color authFieldBorder = Color(0xFF1E3A5F);
  static const Color authCardTint = Color(0x1AFFFFFF);
  static const Color authCardBorder = Color(0x33FFFFFF);
  static const Color authDivider = Color(0xFF3D5A73);
  static const Color authCheckboxBorder = Color(0xFF5A7A94);

  static const LinearGradient authScaffoldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [authBackgroundTop, Color(0xFF062A4A), authBackgroundBottom],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient authPrimaryButtonGradient = LinearGradient(
    colors: [Color(0xFF5EC8FF), brandBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static final BoxDecoration authGlassCardDecoration = BoxDecoration(
    color: authCardTint,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: authCardBorder),
  );

  // --- Home feed (aligned with [FaithAppColors.dark]) ---
  static const Color feedScaffoldBackground = Color(0xFF0F1115);
  static const Color feedCardBackground = Color(0xFF1A1D23);
  static const Color feedNavBarBackground = Color(0xFF141820);
  static const Color feedMutedText = Color(0xFF8B929E);
  static const Color feedTagBackground = Color(0xFF252A33);
  static const Color feedLiveGradientStart = Color(0xFFE91E8C);
  static const Color feedLiveGradientEnd = Color(0xFFFF6B6B);
  static const Color feedEventLabel = Color(0xFFFF9F43);

  // --- Chat ---
  static const Color chatScaffoldBackground = feedScaffoldBackground;
  static const Color chatCardBackground = feedCardBackground;
  static const Color chatSegmentTrack = Color(0xFF141820);
  static const Color chatBubbleIncoming = Color(0xFF1E293B);
  static const Color chatBubbleOutgoing = primary300;
  static const Color chatBubbleOutgoingText = brandNavy;
  static const Color chatInputBackground = Color(0xFF1A1D23);
  static const Color chatMutedText = feedMutedText;
  static const Color chatTitleAccent = primary300;
  static const Color chatModeratorAccent = Color(0xFFE99B00);
  static const Color chatDateSeparator = Color(0xFF6B7280);
  static const Color chatOnlineIndicator = greenSuccess500;

  static const LinearGradient chatSegmentActiveGradient = LinearGradient(
    colors: [Color(0xFF5EC8FF), brandBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // --- Sidebar ---
  static const Color sidebarBackground = Color(0xFF12151C);
  static const Color sidebarSurface = Color(0xFF1C2129);
  static const Color sidebarSurfaceElevated = Color(0xFF232830);
  static const Color sidebarSelected = Color(0xFF0096FF);
  static const Color sidebarSectionLabel = Color(0xFF6B7280);
  static const Color sidebarItemText = Color(0xFF9CA3AF);
  static const Color sidebarAdminBadge = Color(0xFF0A92E7);
}

ThemeData darkThemeData(BuildContext context) {
  const Color primary = DarkTheme.primary400;
  const Color primaryContainer = DarkTheme.primary700;
  const Color secondary = DarkTheme.secondary400;

  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: DarkTheme.primary100,
    secondary: secondary,
    onSecondary: DarkTheme.secondary950,
    secondaryContainer: DarkTheme.secondary700,
    onSecondaryContainer: DarkTheme.secondary100,
    surface: DarkTheme.secondary900,
    onSurface: DarkTheme.secondary50,
    surfaceContainer: DarkTheme.secondary800,
    onSurfaceVariant: DarkTheme.secondary300,
    error: DarkTheme.redDanger400,
    onError: DarkTheme.redDanger950,
    errorContainer: DarkTheme.redDanger900,
    onErrorContainer: DarkTheme.redDanger100,
    tertiary: DarkTheme.accent400,
    onTertiary: DarkTheme.accent950,
    tertiaryContainer: DarkTheme.accent800,
    onTertiaryContainer: DarkTheme.accent100,
    outline: DarkTheme.grey300,
    outlineVariant: DarkTheme.grey700,
  );

  final extendedScheme = scheme.withCustomColors(
    success: DarkTheme.greenSuccess400,
    warning: DarkTheme.yellowWarning400,
    info: DarkTheme.blueInfo400,
  );

  final size = MediaQuery.of(context).size;
  final width = size.width;
  final isTablet = width >= 600;
  final double scale = isTablet ? 1.3 : 1.0;

  TextStyle style(double size, FontWeight weight, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: size * scale,
      fontWeight: weight,
      color: color ?? scheme.onSurface,
      letterSpacing: 0,
    );
  }

  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: extendedScheme,
    scaffoldBackgroundColor: DarkTheme.feedScaffoldBackground,
    canvasColor: DarkTheme.feedCardBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: style(20, FontWeight.w500),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    iconTheme: IconThemeData(color: scheme.onSurface, size: 24 * scale),
    textTheme: TextTheme(
      displayLarge: style(96, FontWeight.w500),
      displayMedium: style(60, FontWeight.w500),
      displaySmall: style(48, FontWeight.w500),
      headlineLarge: style(40, FontWeight.w500),
      headlineMedium: style(32, FontWeight.w500),
      headlineSmall: style(24, FontWeight.w500),
      titleLarge: style(20, FontWeight.w500),
      titleMedium: style(16, FontWeight.w500),
      titleSmall: style(14, FontWeight.w500),
      bodyLarge: style(16, FontWeight.w400),
      bodyMedium: style(14, FontWeight.w400),
      bodySmall: style(12, FontWeight.w400),
      labelLarge: style(14, FontWeight.w500),
      labelMedium: style(12, FontWeight.w500, color: DarkTheme.feedMutedText),
      labelSmall: style(10, FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: DarkTheme.primary950,
        elevation: 0,
        shape: const CircleBorder(),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        padding: const EdgeInsets.all(24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DarkTheme.primary200,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: DarkTheme.primary800.withValues(alpha: 0.3),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: DarkTheme.feedNavBarBackground,
      selectedItemColor: DarkTheme.brandBlue,
      unselectedItemColor: DarkTheme.feedMutedText,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DarkTheme.brandBlue,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: CircleBorder(),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: DarkTheme.feedNavBarBackground,
      elevation: 0,
    ),
    extensions: <ThemeExtension<dynamic>>[FaithAppColors.dark],
  );
}
