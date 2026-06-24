import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  // Grid Base Unit
  static const double baseUnit = 8.0;

  // Vertical Spacing (Sizedbox)
  static final SizedBox v4 = SizedBox(height: 4.h);
  static final SizedBox v8 = SizedBox(height: 8.h);
  static final SizedBox v12 = SizedBox(height: 12.h);
  static final SizedBox v16 = SizedBox(height: 16.h);
  static final SizedBox v20 = SizedBox(height: 20.h);
  static final SizedBox v24 = SizedBox(height: 24.h);
  static final SizedBox v32 = SizedBox(height: 32.h);

  // Horizontal Spacing (Sizedbox)
  static final SizedBox h8 = SizedBox(width: 8.w);
  static final SizedBox h12 = SizedBox(width: 12.w);
  static final SizedBox h16 = SizedBox(width: 16.w);
  static final SizedBox h20 = SizedBox(width: 20.w);
  static final SizedBox h24 = SizedBox(width: 24.w);

  // Screen Padding
  static final EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 16.h,
  );
  static final EdgeInsets paddingHorizontal24 = EdgeInsets.symmetric(
    horizontal: 24.w,
  );

  // Section Spacing
  static final EdgeInsets sectionVertical = EdgeInsets.symmetric(
    vertical: 24.h,
  );
  static final double sectionSpacing = 24.h;

  // Card Padding & Spacing
  static final EdgeInsets cardPadding = EdgeInsets.all(16.r);
  static final double betweenCards = 16.h;
  static final double cardInsideSpacing = 12.h;

  // List Item Padding & Spacing
  static final EdgeInsets listItemPadding = EdgeInsets.all(12.r);
  static final double betweenListItems = 12.h;

  // Button Padding & Height
  static final EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: 12.h,
    horizontal: 16.w,
  );
  static final double buttonHeight = 48.h;

  // Form Spacing
  static final double fieldSpacing = 16.h;
  static final double labelSpacing = 4.h;

  // Spacing Rules
  static final double betweenSections = 24.h;
  static final double betweenTextElements = 8.h;
  static final double smallSpacing = 8.h;
  static final double componentSpacing = 16.h;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double base = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // Standard Border Radius
  static final BorderRadius small = BorderRadius.circular(sm.r);
  static final BorderRadius card = BorderRadius.circular(base.r);
  static final BorderRadius medium = BorderRadius.circular(base.r);
  static final BorderRadius large = BorderRadius.circular(lg.r);
  static final BorderRadius button = BorderRadius.circular(sm.r);
  static final BorderRadius extraLarge = BorderRadius.circular(xl.r);
  
  static const double circular = 100.0;
}
