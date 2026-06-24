import 'package:faithconnect/core/theme/app_theme_extensions.dart';

import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';



/// Branded gradient shell for login and sign-up.

class AuthBackground extends StatelessWidget {

  final Widget child;



  const AuthBackground({super.key, required this.child});



  @override

  Widget build(BuildContext context) {

    final auth = context.authPalette;

    final isDark = context.isDarkMode;

    final colors = context.faithColors;



    return AnnotatedRegion<SystemUiOverlayStyle>(

      value: context.faithStatusBarOverlay,

      child: DecoratedBox(

        decoration: BoxDecoration(

          color: isDark ? null : auth.formBackgroundColor,

          gradient: auth.formGradient,

        ),

        child: Stack(

          fit: StackFit.expand,

          children: [

            if (!isDark) ..._lightFormAccents(colors.brandBlue),

            child,

          ],

        ),

      ),

    );

  }



  List<Widget> _lightFormAccents(Color brandBlue) {

    return [

      Positioned(

        top: -72.h,

        right: -48.w,

        child: _AuthGlowOrb(

          diameter: 220.r,

          color: brandBlue.withValues(alpha: 0.14),

        ),

      ),

      Positioned(

        top: 120.h,

        left: -64.w,

        child: _AuthGlowOrb(

          diameter: 180.r,

          color: brandBlue.withValues(alpha: 0.08),

        ),

      ),

      Positioned(

        bottom: -40.h,

        right: 24.w,

        child: _AuthGlowOrb(

          diameter: 140.r,

          color: const Color(0xFF0A92E7).withValues(alpha: 0.1),

        ),

      ),

    ];

  }

}



class _AuthGlowOrb extends StatelessWidget {

  final double diameter;

  final Color color;



  const _AuthGlowOrb({

    required this.diameter,

    required this.color,

  });



  @override

  Widget build(BuildContext context) {

    return IgnorePointer(

      child: Container(

        width: diameter,

        height: diameter,

        decoration: BoxDecoration(

          shape: BoxShape.circle,

          gradient: RadialGradient(

            colors: [color, color.withValues(alpha: 0)],

          ),

        ),

      ),

    );

  }

}

