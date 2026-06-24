import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Breakpoints and layout helpers for phone, tablet, and desktop widths.
class ResponsiveHelper {
  ResponsiveHelper(this.context)
      : size = MediaQuery.sizeOf(context),
        orientation = MediaQuery.orientationOf(context),
        padding = MediaQuery.paddingOf(context);

  final BuildContext context;
  final Size size;
  final Orientation orientation;
  final EdgeInsets padding;

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static ResponsiveHelper of(BuildContext context) => ResponsiveHelper(context);

  double get width => size.width;
  double get height => size.height;

  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  bool get isMobile => width < mobileBreakpoint;
  bool get isTablet =>
      width >= mobileBreakpoint && width < desktopBreakpoint;
  bool get isDesktop => width >= desktopBreakpoint;
  bool get isCompactWidth => width < 360;

  /// Max readable content width; full width on phones.
  double get contentMaxWidth {
    if (isDesktop) return 960;
    if (isTablet) return 720;
    return width;
  }

  /// Horizontal inset that centers content on wide screens.
  double get contentSideInset {
    if (width <= contentMaxWidth) return 0;
    return (width - contentMaxWidth) / 2;
  }

  /// Page gutter: larger on tablets, centered on wide layouts.
  EdgeInsets pagePadding({
    double top = 0,
    double bottom = 0,
    double horizontal = 16,
  }) {
    final gutter = isTablet ? math.max(horizontal, 24) : horizontal;
    final resolved = isDesktop ? math.max(gutter, 32) : gutter;

    return EdgeInsets.fromLTRB(
      contentSideInset + resolved.w,
      top.h,
      contentSideInset + resolved.w,
      bottom.h,
    );
  }

  EdgeInsets symmetricPagePadding({
    double vertical = 0,
    double horizontal = 16,
  }) {
    return pagePadding(top: vertical, bottom: vertical, horizontal: horizontal);
  }

  int gridColumns({
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
    int? landscapeMobile,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    if (isLandscape && landscapeMobile != null) return landscapeMobile;
    if (isLandscape && width >= 500) return math.max(mobile, 3);
    return mobile;
  }

  int get shortsGridColumns => gridColumns(
        mobile: 2,
        tablet: 3,
        desktop: 4,
        landscapeMobile: 3,
      );

  double get bottomNavClearance {
    if (isLandscape) return math.max(64.h, 48);
    return 88.h;
  }

  double get feedItemGap => isCompactWidth ? 12.h : 16.h;
}

extension ResponsiveBuildContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper.of(this);
}
