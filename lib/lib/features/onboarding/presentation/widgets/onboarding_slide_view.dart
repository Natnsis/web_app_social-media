import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// One onboarding page: hero image and text card scroll/swipe together.
class OnboardingSlideView extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingSlideView({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final scaffoldColor =
        isDark ? DarkTheme.brandNavy : colors.scaffoldBackground;

    return ColoredBox(
      color: scaffoldColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * 0.52;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: heroHeight,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            slide.backgroundAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            width: double.infinity,
                            height: double.infinity,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: isDark
                                  ? const Color(0xFF0C2A45)
                                  : colors.tagBackground,
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48.r,
                                  color: colors.mutedText,
                                ),
                              ),
                            ),
                          ),
                          _OnboardingHeroOverlays(
                            isDark: isDark,
                            bottomColor: scaffoldColor,
                            brandSky: colors.brandSky,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                      child: OnboardingSlideContent(slide: slide),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Layered scrims so hero photos blend into the slide body (light + dark).
class _OnboardingHeroOverlays extends StatelessWidget {
  final bool isDark;
  final Color bottomColor;
  final Color brandSky;

  const _OnboardingHeroOverlays({
    required this.isDark,
    required this.bottomColor,
    required this.brandSky,
  });

  @override
  Widget build(BuildContext context) {
    // Bottom-only scrim: top / app-bar area stays clear; lighter fade overall.
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: isDark ? 0.42 : 0.4,
        widthFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      DarkTheme.brandNavy.withValues(alpha: 0.22),
                      DarkTheme.brandNavy.withValues(alpha: 0.55),
                      bottomColor,
                    ],
                    stops: const [0.0, 0.45, 0.82, 1.0],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      brandSky.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.58),
                      bottomColor,
                    ],
                    stops: const [0.0, 0.35, 0.62, 0.88, 1.0],
                  ),
          ),
        ),
      ),
    );
  }
}

class OnboardingSlideContent extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingSlideContent({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    final titleStyle = GoogleFonts.inter(
      fontSize: 30.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      color: colors.headerTitle,
      height: 1.15,
    );

    final descriptionStyle = GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: isDark ? const Color(0xFFB8C4CE) : colors.secondaryText,
      height: 1.55,
    );

    final footerStyle = GoogleFonts.inter(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.35,
      color: isDark ? const Color(0xFF4A6B8A) : colors.mutedText,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: titleStyle,
        ),
        SizedBox(height: 14.h),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: descriptionStyle,
        ),
        if (slide.footerLabel != null) ...[
          SizedBox(height: 18.h),
          Text(
            slide.footerLabel!,
            textAlign: TextAlign.center,
            style: footerStyle,
          ),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: isDark
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: content,
            )
          : Material(
              clipBehavior: Clip.none,
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 22.h,
                ),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: colors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: content,
              ),
            ),
    );
  }
}
