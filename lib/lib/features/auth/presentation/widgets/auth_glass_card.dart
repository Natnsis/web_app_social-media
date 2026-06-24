import 'dart:ui';



import 'package:faithconnect/core/theme/app_theme_extensions.dart';

import 'package:faithconnect/features/auth/presentation/theme/auth_theme.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';



class AuthGlassCard extends StatelessWidget {

  final Widget child;



  const AuthGlassCard({super.key, required this.child});



  @override

  Widget build(BuildContext context) {

    final auth = context.authPalette;

    final isDark = context.isDarkMode;

    final colors = context.faithColors;



    final card = Container(

      width: double.infinity,

      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),

      decoration: BoxDecoration(

        color: auth.glassFill,

        borderRadius: BorderRadius.circular(24.r),

        border: Border.all(color: auth.glassBorder),

        boxShadow: isDark

            ? null

            : [

                BoxShadow(

                  color: colors.brandBlue.withValues(alpha: 0.06),

                  blurRadius: 32,

                  offset: const Offset(0, 12),

                ),

                BoxShadow(

                  color: Colors.black.withValues(alpha: 0.04),

                  blurRadius: 16,

                  offset: const Offset(0, 4),

                ),

              ],

      ),

      child: child,

    );



    return ClipRRect(

      borderRadius: BorderRadius.circular(24.r),

      child: isDark

          ? BackdropFilter(

              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

              child: card,

            )

          : card,

    );

  }

}

