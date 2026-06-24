import 'package:flutter/material.dart';
import 'dark_theme.dart';

extension CustomColorScheme on ColorScheme {
  Color get success => _success;
  Color get warning => _warning;
  Color get info => _info;

  static const Color _success = Color(0xFF43b75d);
  static const Color _warning = Color(0xFFe99b00);
  static const Color _info = Color(0xFF0095ff);

  ColorScheme withCustomColors({
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return _CustomColorScheme(
      this,
      success: success ?? _success,
      warning: warning ?? _warning,
      info: info ?? _info,
    );
  }
}

class _CustomColorScheme extends ColorScheme {
  final Color _success;
  final Color _warning;
  final Color _info;

  _CustomColorScheme(
    ColorScheme base, {
    required Color success,
    required Color warning,
    required Color info,
  })  : _success = success,
        _warning = warning,
        _info = info,
        super(
          brightness: base.brightness,
          primary: base.primary,
          onPrimary: base.onPrimary,
          primaryContainer: base.primaryContainer,
          onPrimaryContainer: base.onPrimaryContainer,
          secondary: base.secondary,
          onSecondary: base.onSecondary,
          secondaryContainer: base.secondaryContainer,
          onSecondaryContainer: base.onSecondaryContainer,
          tertiary: base.tertiary,
          onTertiary: base.onTertiary,
          tertiaryContainer: base.tertiaryContainer,
          onTertiaryContainer: base.onTertiaryContainer,
          error: base.error,
          onError: base.onError,
          errorContainer: base.errorContainer,
          onErrorContainer: base.onErrorContainer,
          surface: base.surface,
          onSurface: base.onSurface,
          surfaceContainerHighest: base.surfaceContainerHighest,
          surfaceContainerHigh: base.surfaceContainerHigh,
          surfaceContainer: base.surfaceContainer,
          surfaceContainerLow: base.surfaceContainerLow,
          surfaceContainerLowest: base.surfaceContainerLowest,
          onSurfaceVariant: base.onSurfaceVariant,
          outline: base.outline,
          outlineVariant: base.outlineVariant,
          shadow: base.shadow,
          scrim: base.scrim,
          inverseSurface: base.inverseSurface,
          onInverseSurface: base.onInverseSurface,
          inversePrimary: base.inversePrimary,
        );

  Color get success => _success;
  Color get warning => _warning;
  Color get info => _info;
}

extension ColorSchemeShades on ColorScheme {
  Color get _p50 => brightness == Brightness.light ? DarkTheme.primary50 : DarkTheme.primary950;
  Color get _p100 => brightness == Brightness.light ? DarkTheme.primary100 : DarkTheme.primary900;
  Color get _p200 => brightness == Brightness.light ? DarkTheme.primary200 : DarkTheme.primary800;
  Color get _p300 => brightness == Brightness.light ? DarkTheme.primary300 : DarkTheme.primary700;
  Color get _p400 => brightness == Brightness.light ? DarkTheme.primary400 : DarkTheme.primary600;
  Color get _p500 => brightness == Brightness.light ? DarkTheme.primary500 : DarkTheme.primary500;
  Color get _p600 => brightness == Brightness.light ? DarkTheme.primary600 : DarkTheme.primary400;
  Color get _p700 => brightness == Brightness.light ? DarkTheme.primary700 : DarkTheme.primary300;
  Color get _p800 => brightness == Brightness.light ? DarkTheme.primary800 : DarkTheme.primary200;
  Color get _p900 => brightness == Brightness.light ? DarkTheme.primary900 : DarkTheme.primary100;
  Color get _p950 => brightness == Brightness.light ? DarkTheme.primary950 : DarkTheme.primary50;

  Color get _s50 => brightness == Brightness.light ? DarkTheme.secondary50 : DarkTheme.secondary950;
  Color get _s100 => brightness == Brightness.light ? DarkTheme.secondary100 : DarkTheme.secondary900;
  Color get _s200 => brightness == Brightness.light ? DarkTheme.secondary200 : DarkTheme.secondary800;
  Color get _s300 => brightness == Brightness.light ? DarkTheme.secondary300 : DarkTheme.secondary700;
  Color get _s400 => brightness == Brightness.light ? DarkTheme.secondary400 : DarkTheme.secondary600;
  Color get _s500 => brightness == Brightness.light ? DarkTheme.secondary500 : DarkTheme.secondary500;
  Color get _s600 => brightness == Brightness.light ? DarkTheme.secondary600 : DarkTheme.secondary400;
  Color get _s700 => brightness == Brightness.light ? DarkTheme.secondary700 : DarkTheme.secondary300;
  Color get _s800 => brightness == Brightness.light ? DarkTheme.secondary800 : DarkTheme.secondary200;
  Color get _s900 => brightness == Brightness.light ? DarkTheme.secondary900 : DarkTheme.secondary100;
  Color get _s950 => brightness == Brightness.light ? DarkTheme.secondary950 : DarkTheme.secondary50;

  Color get _a50 => brightness == Brightness.light ? DarkTheme.accent50 : DarkTheme.accent950;
  Color get _a100 => brightness == Brightness.light ? DarkTheme.accent100 : DarkTheme.accent900;
  Color get _a200 => brightness == Brightness.light ? DarkTheme.accent200 : DarkTheme.accent800;
  Color get _a300 => brightness == Brightness.light ? DarkTheme.accent300 : DarkTheme.accent700;
  Color get _a400 => brightness == Brightness.light ? DarkTheme.accent400 : DarkTheme.accent600;
  Color get _a500 => brightness == Brightness.light ? DarkTheme.accent500 : DarkTheme.accent500;
  Color get _a600 => brightness == Brightness.light ? DarkTheme.accent600 : DarkTheme.accent400;
  Color get _a700 => brightness == Brightness.light ? DarkTheme.accent700 : DarkTheme.accent300;
  Color get _a800 => brightness == Brightness.light ? DarkTheme.accent800 : DarkTheme.accent200;
  Color get _a900 => brightness == Brightness.light ? DarkTheme.accent900 : DarkTheme.accent100;
  Color get _a950 => brightness == Brightness.light ? DarkTheme.accent950 : DarkTheme.accent50;

  Color get _g50 => brightness == Brightness.light ? DarkTheme.grey50 : DarkTheme.grey950;
  Color get _g100 => brightness == Brightness.light ? DarkTheme.grey100 : DarkTheme.grey900;
  Color get _g200 => brightness == Brightness.light ? DarkTheme.grey200 : DarkTheme.grey800;
  Color get _g300 => brightness == Brightness.light ? DarkTheme.grey300 : DarkTheme.grey700;
  Color get _g400 => brightness == Brightness.light ? DarkTheme.grey400 : DarkTheme.grey600;
  Color get _g500 => brightness == Brightness.light ? DarkTheme.grey500 : DarkTheme.grey500;
  Color get _g600 => brightness == Brightness.light ? DarkTheme.grey600 : DarkTheme.grey400;
  Color get _g700 => brightness == Brightness.light ? DarkTheme.grey700 : DarkTheme.grey300;
  Color get _g800 => brightness == Brightness.light ? DarkTheme.grey800 : DarkTheme.grey200;
  Color get _g900 => brightness == Brightness.light ? DarkTheme.grey900 : DarkTheme.grey100;
  Color get _g950 => brightness == Brightness.light ? DarkTheme.grey950 : DarkTheme.grey50;

  Color get primary50 => _p50;
  Color get primary100 => _p100;
  Color get primary200 => _p200;
  Color get primary300 => _p300;
  Color get primary400 => _p400;
  Color get primary500 => _p500;
  Color get primary600 => _p600;
  Color get primary700 => _p700;
  Color get primary800 => _p800;
  Color get primary900 => _p900;
  Color get primary950 => _p950;

  Color get secondary50 => _s50;
  Color get secondary100 => _s100;
  Color get secondary200 => _s200;
  Color get secondary300 => _s300;
  Color get secondary400 => _s400;
  Color get secondary500 => _s500;
  Color get secondary600 => _s600;
  Color get secondary700 => _s700;
  Color get secondary800 => _s800;
  Color get secondary900 => _s900;
  Color get secondary950 => _s950;

  Color get accent50 => _a50;
  Color get accent100 => _a100;
  Color get accent200 => _a200;
  Color get accent300 => _a300;
  Color get accent400 => _a400;
  Color get accent500 => _a500;
  Color get accent600 => _a600;
  Color get accent700 => _a700;
  Color get accent800 => _a800;
  Color get accent900 => _a900;
  Color get accent950 => _a950;

  Color get _sc50 => brightness == Brightness.light ? DarkTheme.greenSuccess50 : DarkTheme.greenSuccess950;
  Color get _sc100 => brightness == Brightness.light ? DarkTheme.greenSuccess100 : DarkTheme.greenSuccess900;
  Color get _sc200 => brightness == Brightness.light ? DarkTheme.greenSuccess200 : DarkTheme.greenSuccess800;
  Color get _sc300 => brightness == Brightness.light ? DarkTheme.greenSuccess300 : DarkTheme.greenSuccess600;
  Color get _sc400 => brightness == Brightness.light ? DarkTheme.greenSuccess400 : DarkTheme.greenSuccess600;
  Color get _sc500 => brightness == Brightness.light ? DarkTheme.greenSuccess500 : DarkTheme.greenSuccess500;
  Color get _sc600 => brightness == Brightness.light ? DarkTheme.greenSuccess600 : DarkTheme.greenSuccess400;
  Color get _sc700 => brightness == Brightness.light ? DarkTheme.greenSuccess600 : DarkTheme.greenSuccess300;
  Color get _sc800 => brightness == Brightness.light ? DarkTheme.greenSuccess800 : DarkTheme.greenSuccess200;
  Color get _sc900 => brightness == Brightness.light ? DarkTheme.greenSuccess900 : DarkTheme.greenSuccess100;
  Color get _sc950 => brightness == Brightness.light ? DarkTheme.greenSuccess950 : DarkTheme.greenSuccess50;

  Color get _e50 => brightness == Brightness.light ? DarkTheme.redDanger50 : DarkTheme.redDanger950;
  Color get _e100 => brightness == Brightness.light ? DarkTheme.redDanger100 : DarkTheme.redDanger900;
  Color get _e200 => brightness == Brightness.light ? DarkTheme.redDanger200 : DarkTheme.redDanger800;
  Color get _e300 => brightness == Brightness.light ? DarkTheme.redDanger300 : DarkTheme.redDanger700;
  Color get _e400 => brightness == Brightness.light ? DarkTheme.redDanger400 : DarkTheme.redDanger600;
  Color get _e500 => brightness == Brightness.light ? DarkTheme.redDanger500 : DarkTheme.redDanger500;
  Color get _e600 => brightness == Brightness.light ? DarkTheme.redDanger600 : DarkTheme.redDanger400;
  Color get _e700 => brightness == Brightness.light ? DarkTheme.redDanger700 : DarkTheme.redDanger300;
  Color get _e800 => brightness == Brightness.light ? DarkTheme.redDanger800 : DarkTheme.redDanger200;
  Color get _e900 => brightness == Brightness.light ? DarkTheme.redDanger900 : DarkTheme.redDanger100;
  Color get _e950 => brightness == Brightness.light ? DarkTheme.redDanger950 : DarkTheme.redDanger50;

  Color get _w50 => brightness == Brightness.light ? DarkTheme.yellowWarning50 : DarkTheme.yellowWarning950;
  Color get _w100 => brightness == Brightness.light ? DarkTheme.yellowWarning100 : DarkTheme.yellowWarning900;
  Color get _w200 => brightness == Brightness.light ? DarkTheme.yellowWarning200 : DarkTheme.yellowWarning800;
  Color get _w300 => brightness == Brightness.light ? DarkTheme.yellowWarning300 : DarkTheme.yellowWarning700;
  Color get _w400 => brightness == Brightness.light ? DarkTheme.yellowWarning400 : DarkTheme.yellowWarning600;
  Color get _w500 => brightness == Brightness.light ? DarkTheme.yellowWarning500 : DarkTheme.yellowWarning500;
  Color get _w600 => brightness == Brightness.light ? DarkTheme.yellowWarning600 : DarkTheme.yellowWarning400;
  Color get _w700 => brightness == Brightness.light ? DarkTheme.yellowWarning700 : DarkTheme.yellowWarning300;
  Color get _w800 => brightness == Brightness.light ? DarkTheme.yellowWarning800 : DarkTheme.yellowWarning200;
  Color get _w900 => brightness == Brightness.light ? DarkTheme.yellowWarning900 : DarkTheme.yellowWarning100;
  Color get _w950 => brightness == Brightness.light ? DarkTheme.yellowWarning950 : DarkTheme.yellowWarning50;

  Color get _i50 => brightness == Brightness.light ? DarkTheme.blueInfo50 : DarkTheme.blueInfo950;
  Color get _i100 => brightness == Brightness.light ? DarkTheme.blueInfo100 : DarkTheme.blueInfo900;
  Color get _i200 => brightness == Brightness.light ? DarkTheme.blueInfo200 : DarkTheme.blueInfo800;
  Color get _i300 => brightness == Brightness.light ? DarkTheme.blueInfo300 : DarkTheme.blueInfo700;
  Color get _i400 => brightness == Brightness.light ? DarkTheme.blueInfo400 : DarkTheme.blueInfo600;
  Color get _i500 => brightness == Brightness.light ? DarkTheme.blueInfo500 : DarkTheme.blueInfo500;
  Color get _i600 => brightness == Brightness.light ? DarkTheme.blueInfo600 : DarkTheme.blueInfo400;
  Color get _i700 => brightness == Brightness.light ? DarkTheme.blueInfo700 : DarkTheme.blueInfo300;
  Color get _i800 => brightness == Brightness.light ? DarkTheme.blueInfo800 : DarkTheme.blueInfo200;
  Color get _i900 => brightness == Brightness.light ? DarkTheme.blueInfo900 : DarkTheme.blueInfo100;
  Color get _i950 => brightness == Brightness.light ? DarkTheme.blueInfo950 : DarkTheme.blueInfo50;

  Color get grey50 => _g50;
  Color get grey100 => _g100;
  Color get grey200 => _g200;
  Color get grey300 => _g300;
  Color get grey400 => _g400;
  Color get grey500 => _g500;
  Color get grey600 => _g600;
  Color get grey700 => _g700;
  Color get grey800 => _g800;
  Color get grey900 => _g900;
  Color get grey950 => _g950;

  Color get success50 => _sc50;
  Color get success100 => _sc100;
  Color get success200 => _sc200;
  Color get success300 => _sc300;
  Color get success400 => _sc400;
  Color get success500 => _sc500;
  Color get success600 => _sc600;
  Color get success700 => _sc700;
  Color get success800 => _sc800;
  Color get success900 => _sc900;
  Color get success950 => _sc950;

  Color get error50 => _e50;
  Color get error100 => _e100;
  Color get error200 => _e200;
  Color get error300 => _e300;
  Color get error400 => _e400;
  Color get error500 => _e500;
  Color get error600 => _e600;
  Color get error700 => _e700;
  Color get error800 => _e800;
  Color get error900 => _e900;
  Color get error950 => _e950;

  Color get warning50 => _w50;
  Color get warning100 => _w100;
  Color get warning200 => _w200;
  Color get warning300 => _w300;
  Color get warning400 => _w400;
  Color get warning500 => _w500;
  Color get warning600 => _w600;
  Color get warning700 => _w700;
  Color get warning800 => _w800;
  Color get warning900 => _w900;
  Color get warning950 => _w950;

  Color get info50 => _i50;
  Color get info100 => _i100;
  Color get info200 => _i200;
  Color get info300 => _i300;
  Color get info400 => _i400;
  Color get info500 => _i500;
  Color get info600 => _i600;
  Color get info700 => _i700;
  Color get info800 => _i800;
  Color get info900 => _i900;
  Color get info950 => _i950;
}