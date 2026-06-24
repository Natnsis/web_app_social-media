import 'package:flutter/material.dart';

/// Supported app languages for the sidebar selector and [LocaleCubit].
///
/// User preference may be Oromo or Sidama, but [materialLocale] falls back to
/// English for Flutter Material widgets (date pickers, text fields, etc.).
enum AppLanguage {
  english('en', 'English', 'English'),
  amharic('am', 'Amharic', 'አማርኛ'),
  oromo('om', 'Afaan Oromo', 'Afaan Oromoo'),
  sidama('sid', 'Sidama', 'Sidaamu Afoo');

  final String code;
  final String label;
  final String nativeLabel;

  const AppLanguage(this.code, this.label, this.nativeLabel);

  Locale get locale => Locale(code);

  /// Whether Flutter provides [MaterialLocalizations] for this language.
  bool get hasMaterialLocalizations =>
      this == AppLanguage.english || this == AppLanguage.amharic;

  /// Locale passed to [MaterialApp.locale] and Material widgets.
  Locale get materialLocale =>
      hasMaterialLocalizations ? locale : const Locale('en');

  /// Only locales Material can load — do not add `om` or `sid` here.
  static const List<Locale> materialSupportedLocales = [
    Locale('en'),
    Locale('am'),
  ];

  static List<Locale> get supportedLocales =>
      AppLanguage.values.map((e) => e.locale).toList();

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}
