import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrandingPageIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final bool useSplashDotStyle;

  const BrandingPageIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    this.useSplashDotStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;

        if (useSplashDotStyle) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? DarkTheme.splashDotActive
                  : DarkTheme.splashDotInactive,
            ),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 28.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive
                ? DarkTheme.brandBlue
                : DarkTheme.onboardingDotInactive,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
