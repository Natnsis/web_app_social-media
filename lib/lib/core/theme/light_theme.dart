import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faithconnect/core/theme/faith_app_colors.dart';
import 'dark_theme.dart';
import 'color_scheme_extensions.dart';

ThemeData themeData(BuildContext context) {
  const Color primary = DarkTheme.primary600;
  const Color primary700 = DarkTheme.primary700;
  const Color secondary = DarkTheme.secondary600;

  final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primary700,
        onPrimaryContainer: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: DarkTheme.secondary100,
        onSecondaryContainer: DarkTheme.secondary900,
        surface: Colors.white,
        onSurface: const Color(0xFF0F172A),
        surfaceContainer: DarkTheme.primary50,
        onSurfaceVariant: const Color(0xFF64748B),
        error: DarkTheme.redDanger600,
        onError: Colors.white,
        errorContainer: DarkTheme.redDanger100,
        onErrorContainer: DarkTheme.redDanger900,
        tertiary: DarkTheme.accent600,
        onTertiary: Colors.white,
        tertiaryContainer: DarkTheme.accent100,
        onTertiaryContainer: DarkTheme.accent900,
        outline: DarkTheme.grey300,
        outlineVariant: DarkTheme.grey200,
      );

  final extendedScheme = scheme.withCustomColors(
    success: DarkTheme.greenSuccess600,
    warning: DarkTheme.yellowWarning600,
    info: DarkTheme.blueInfo600,
  );

  // Responsive font sizing logic
  final size = MediaQuery.of(context).size;
  final width = size.width;
  // Base width for mobile logic (iPhone 8/SE width is ~375, modern phones ~390-430)
  // We can use a simple scaling factor or stick to breakpoints.
  // User asked for "responsive phont size" for "tablet view".
  final isTablet = width >= 600;
  final double scale = isTablet ? 1.3 : 1.0;
  // Helper to generate responsive text styles
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

    scaffoldBackgroundColor: FaithAppColors.light.scaffoldBackground,
    canvasColor: FaithAppColors.light.cardBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: style(20, FontWeight.w500),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
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
      labelMedium: style(12, FontWeight.w500, color: Color(0xFF939BAC)),
      labelSmall: style(10, FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        padding: const EdgeInsets.all(24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: 0.9),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: FaithAppColors.light.navBarBackground,
      selectedItemColor: primary,
      unselectedItemColor: FaithAppColors.light.mutedText,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: FaithAppColors.light.brandBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 6,
      shape: const CircleBorder(),
    ),

    bottomAppBarTheme: BottomAppBarThemeData(
      color: DarkTheme.primary50,
      elevation: 0,
    ),
    extensions: <ThemeExtension<dynamic>>[FaithAppColors.light],
  );
}
