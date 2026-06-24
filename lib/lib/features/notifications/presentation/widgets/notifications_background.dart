import 'dart:ui';



import 'package:faithconnect/core/theme/app_theme_extensions.dart';

import 'package:faithconnect/core/theme/dark_theme.dart';

import 'package:flutter/material.dart';



/// Ambient backdrop for the notifications screen — neon orbs in dark mode only.

class NotificationsBackground extends StatelessWidget {

  final Widget child;



  const NotificationsBackground({super.key, required this.child});



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;

    final isDark = context.isDarkMode;



    return Stack(

      fit: StackFit.expand,

      children: [

        DecoratedBox(

          decoration: BoxDecoration(

            color: colors.scaffoldBackground,

            gradient: isDark

                ? const LinearGradient(

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,

                    colors: [

                      Color(0xFF06080D),

                      Color(0xFF0A1220),

                      Color(0xFF0D1528),

                      Color(0xFF06080D),

                    ],

                    stops: [0.0, 0.35, 0.72, 1.0],

                  )

                : null,

          ),

        ),

        if (isDark) ...[

          Positioned(

            top: -80,

            right: -40,

            child: _NeonOrb(

              size: 220,

              colors: [

                DarkTheme.brandBlue.withValues(alpha: 0.35),

                DarkTheme.accent500.withValues(alpha: 0.12),

              ],

            ),

          ),

          Positioned(

            top: 180,

            left: -60,

            child: _NeonOrb(

              size: 180,

              colors: [

                DarkTheme.feedLiveGradientStart.withValues(alpha: 0.22),

                DarkTheme.accent600.withValues(alpha: 0.08),

              ],

            ),

          ),

          Positioned(

            bottom: 120,

            right: -20,

            child: _NeonOrb(

              size: 160,

              colors: [

                DarkTheme.primary500.withValues(alpha: 0.18),

                Colors.transparent,

              ],

            ),

          ),

        ],

        child,

      ],

    );

  }

}



class _NeonOrb extends StatelessWidget {

  final double size;

  final List<Color> colors;



  const _NeonOrb({

    required this.size,

    required this.colors,

  });



  @override

  Widget build(BuildContext context) {

    return ImageFiltered(

      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),

      child: Container(

        width: size,

        height: size,

        decoration: BoxDecoration(

          shape: BoxShape.circle,

          gradient: RadialGradient(colors: colors),

        ),

      ),

    );

  }

}


