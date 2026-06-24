import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

extension AppTranslationExtension on BuildContext {
  String tr(String key, {Map<String, String>? translationParams}) {
    return FlutterI18n.translate(
      this,
      key,
      translationParams: translationParams,
    );
  }
}
