import 'package:faithconnect/core/locale/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Material / widget localizations for FaithConnect.
///
/// Oromo and Sidama are stored as the user's [AppLanguage] but Flutter does not
/// ship [MaterialLocalizations] for `om` or `sid` — use [AppLanguage.materialLocale].
abstract final class FaithLocalization {
  FaithLocalization._();

  static List<LocalizationsDelegate<dynamic>> get delegates => [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: 'assets/translations',
            fallbackFile: 'en',
            useCountryCode: false,
          ),
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Locales that Flutter can load for Material widgets.
  static const List<Locale> materialSupportedLocales =
      AppLanguage.materialSupportedLocales;

  /// Ensures [child] has Material/Widgets/Cupertino localizations (e.g. modals).
  static Widget scope({
    required Locale locale,
    required Widget child,
  }) {
    return Localizations(
      locale: locale,
      delegates: delegates,
      child: child,
    );
  }
}
