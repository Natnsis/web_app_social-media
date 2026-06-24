import 'package:faithconnect/core/theme/app_theme_extensions.dart';

import 'package:flutter/material.dart';



/// Auth / splash marketing colors for light and dark mode.

class AuthPalette {

  final Gradient formGradient;

  final Color? formBackgroundColor;

  final Gradient? splashGradient;

  final Color splashBackground;

  final Color titleColor;

  final Color subtitleColor;

  final Color fieldFill;

  final Color fieldBorder;

  final Color glassFill;

  final Color glassBorder;

  final Color surfaceFill;

  final Color surfaceBorder;

  final Color checkboxBorder;

  final LinearGradient primaryButtonGradient;



  const AuthPalette({

    required this.formGradient,

    this.formBackgroundColor,

    this.splashGradient,

    required this.splashBackground,

    required this.titleColor,

    required this.subtitleColor,

    required this.fieldFill,

    required this.fieldBorder,

    required this.glassFill,

    required this.glassBorder,

    required this.surfaceFill,

    required this.surfaceBorder,

    required this.checkboxBorder,

    required this.primaryButtonGradient,

  });



  static AuthPalette of(BuildContext context) {

    final colors = context.faithColors;

    final isDark = context.isDarkMode;



    const buttonGradient = LinearGradient(

      colors: [Color(0xFF33B5FF), Color(0xFF0096FF)],

      begin: Alignment.centerLeft,

      end: Alignment.centerRight,

    );



    if (isDark) {

      return const AuthPalette(

        formGradient: LinearGradient(

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [Color(0xFF001428), Color(0xFF062A4A), Color(0xFF0C4A7A)],

        ),

        splashGradient: LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [Color(0xFF001A2C), Color(0xFF003D66), Color(0xFF0096FF)],

        ),

        splashBackground: Color(0xFF001A2C),

        titleColor: Colors.white,

        subtitleColor: Color(0xFFB8C4CE),

        fieldFill: Color(0xFF0D1F33),

        fieldBorder: Color(0xFF1E3A5F),

        glassFill: Color(0x1AFFFFFF),

        glassBorder: Color(0x33FFFFFF),

        surfaceFill: Color(0xFF1C2129),

        surfaceBorder: Color(0xFF2A3038),

        checkboxBorder: Color(0xFF5A7A94),

        primaryButtonGradient: buttonGradient,

      );

    }



    return AuthPalette(

      formGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
      ),
      formBackgroundColor: Color(0xFFFFFFFF),

      splashGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF8FBFF),
          Color(0xFFF0F7FF),
        ],
        stops: [0.0, 0.55, 1.0],
      ),

      splashBackground: colors.scaffoldBackground,

      titleColor: colors.primaryText,

      subtitleColor: colors.mutedText,

      fieldFill: const Color(0xFFF8FAFC),

      fieldBorder: const Color(0xFFE2E8F0),

      glassFill: Colors.white,

      glassBorder: const Color(0xFFE2E8F0),

      surfaceFill: Colors.white,

      surfaceBorder: const Color(0xFFE2E8F0),

      checkboxBorder: colors.mutedText,

      primaryButtonGradient: buttonGradient,

    );

  }

}



extension AuthThemeContext on BuildContext {

  AuthPalette get authPalette => AuthPalette.of(this);

}

