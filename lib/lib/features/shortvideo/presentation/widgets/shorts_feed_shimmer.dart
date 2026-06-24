import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Full-screen placeholder while the shorts feed loads.
class ShortsFeedShimmer extends StatelessWidget {
  const ShortsFeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final fill = faithShimmerFill(context);
    final screen = faithShimmerScreenFill(context);
    final isDark = context.isDarkMode;

    return FaithShimmer(
      child: ColoredBox(
        color: screen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Icon(
                Icons.play_circle_outline_rounded,
                size: 72.r,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : context.faithColors.mutedText.withValues(alpha: 0.35),
              ),
            ),
            Positioned(
              right: 12.w,
              bottom: 100.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: index < 3 ? 20.h : 0),
                    child: _ShimmerCircle(size: 44.r, fill: fill),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              right: 72.w,
              bottom: 28.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerLine(width: 140.w, height: 14.h, fill: fill),
                  SizedBox(height: 10.h),
                  _ShimmerLine(width: 220.w, height: 18.h, fill: fill),
                  SizedBox(height: 8.h),
                  _ShimmerLine(width: 180.w, height: 12.h, fill: fill),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;
  final Color fill;

  const _ShimmerCircle({required this.size, required this.fill});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final Color fill;

  const _ShimmerLine({
    required this.width,
    required this.height,
    required this.fill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
