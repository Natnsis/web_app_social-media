import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';

/// Persisted theme mode identifiers stored in [SharedPrefsService].
class AppTheme {
  AppTheme._();

  static const ThemeMode light = ThemeMode.light;
  static const ThemeMode dark = ThemeMode.dark;
  static const ThemeMode system = ThemeMode.system;

  static ThemeMode fromString(String? themeMode) {
    return switch (themeMode) {
      'dark' => dark,
      'light' => light,
      'system' => system,
      _ => dark,
    };
  }

  static String themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
  }
}

/// Controls app-wide [ThemeMode] and persists the user preference.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(AppTheme.dark);

  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Loads saved preference; call once during app startup before [runApp].
  Future<void> load() async {
    final stored = await SharedPrefsService.getTheme();
    emit(AppTheme.fromString(stored));
    _loaded = true;
  }

  Future<void> changeTheme(ThemeMode mode) async {
    await SharedPrefsService.setTheme(AppTheme.themeModeToString(mode));
    emit(mode);
  }

  /// Toggles between light and dark based on the effective brightness.
  Future<void> toggleTheme(Brightness platformBrightness) async {
    final isDark = _isDark(state, platformBrightness);
    await changeTheme(isDark ? AppTheme.light : AppTheme.dark);
  }

  bool isDarkMode(Brightness platformBrightness) {
    return _isDark(state, platformBrightness);
  }

  static bool _isDark(ThemeMode mode, Brightness platformBrightness) {
    return switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
  }
}
