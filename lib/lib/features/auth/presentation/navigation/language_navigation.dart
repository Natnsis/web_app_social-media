import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class LanguageNavigation {
  LanguageNavigation._();

  static void openLanguage(BuildContext context) {
    context.pushNamed(RoutesConstant.language);
  }
}
