import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/core/theme/light_theme.dart';
import 'package:flutter/material.dart';

/// Light [ThemeData] with [FaithAppColors] registered on the theme.
ThemeData buildLightTheme(BuildContext context) => themeData(context);

/// Dark [ThemeData] with [FaithAppColors] registered on the theme.
ThemeData buildDarkTheme(BuildContext context) => darkThemeData(context);
