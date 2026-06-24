import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Compact dark / light toggle for app bars and settings headers.
class AppThemeModeSwitch extends StatelessWidget {
  const AppThemeModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, themeMode) {
        final colors = context.faithColors;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Semantics(
          button: true,
          label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          child: GestureDetector(
            onTap: () => context.read<ThemeCubit>().toggleTheme(
                  MediaQuery.platformBrightnessOf(context),
                ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: 56.w,
              height: 30.h,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TrackIcon(
                        icon: Iconsax.sun_1,
                        active: !isDark,
                      ),
                      _TrackIcon(
                        icon: Iconsax.moon,
                        active: isDark,
                      ),
                    ],
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    alignment:
                        isDark ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        color: isDark ? colors.brandBlue : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isDark ? Iconsax.moon : Iconsax.sun_1,
                        size: 14.r,
                        color: isDark ? Colors.white : colors.brandBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrackIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _TrackIcon({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Icon(
        icon,
        size: 14.r,
        color: active
            ? Colors.transparent
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.white38
                : Colors.black26),
      ),
    );
  }
}
