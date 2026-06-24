import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_scheme_extensions.dart';
import 'faith_app_colors.dart';

/// Theme-aware colors from the active [ThemeData] (respects light/dark mode).
extension AppThemeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  ColorScheme get colorScheme => appTheme.colorScheme;

  /// Extended palette (primary50, grey500, success, warning, info, …).
  ColorScheme get appColors => colorScheme;

  /// Semantic FaithConnect colors (scaffold, cards, feed, nav, …).
  FaithAppColors get faithColors => FaithAppColors.of(this);

  bool get isDarkMode => appTheme.brightness == Brightness.dark;

  /// Status bar icons that contrast with [faithColors.scaffoldBackground].
  SystemUiOverlayStyle get faithStatusBarOverlay => isDarkMode
      ? const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        )
      : const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        );

  Color get primary => colorScheme.primary;

  Color get onPrimary => colorScheme.onPrimary;

  Color get surface => colorScheme.surface;

  Color get onSurface => colorScheme.onSurface;

  Color get success => colorScheme.success;

  Color get warning => colorScheme.warning;

  Color get info => colorScheme.info;
}
