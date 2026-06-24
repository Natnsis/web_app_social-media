import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Fixed-size shell so account hub metric rows share the same height and width.
class ProfileHubCardShell extends StatelessWidget {
  static const double cardHeight = 80;
  static const double cardBorderRadius = 24;

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const ProfileHubCardShell({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  static EdgeInsetsGeometry hubPadding() {
    return EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight.h,
      width: double.infinity,
      child: AppCompactCard(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        padding: padding ?? hubPadding(),
        child: Align(
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}
