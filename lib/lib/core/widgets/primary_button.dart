import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:faithconnect/core/core.dart';
import '../theme/app_text_styles.dart';
import '../constants/spacing_radius.dart';

enum ButtonRadius { square, rounded, full }

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isDisabled;
  final double paddingVertical;
  final double? paddingHorizontal;
  final ButtonRadius radiusVariant;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool isGradient;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final double elevation;
  final double? fontSize;
  final double? width;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isDisabled = false,
    this.paddingVertical = 16.0,
    this.paddingHorizontal,
    this.radiusVariant = ButtonRadius.full, // default
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isGradient = false,
    this.prefixIcon,
    this.suffixIcon,
    this.elevation = 0,
    this.fontSize,
    this.width,
    this.height,
  });

  /// Full-width gradient publish CTA for compose screens.
  factory PrimaryButton.publish({
    Key? key,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      key: key,
      text: 'Publish',
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isGradient: true,
      textColor: Colors.white,
      radiusVariant: ButtonRadius.full,
      height: 52.h,
      paddingVertical: 14,
      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
    );
  }

  /// Feed, church profile, and dark-scaffold primary actions.
  factory PrimaryButton.feedAction({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    double? width,
    bool isLoading = false,
    bool isDisabled = false,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
    double? fontSize,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: backgroundColor ?? DarkTheme.brandBlue,
      textColor: textColor ?? Colors.white,
      radiusVariant: ButtonRadius.rounded,
      height: 44.h,
      paddingVertical: 12,
      paddingHorizontal: 12.w,
      width: width,
      icon: icon,
      fontSize: fontSize ?? 14.sp,
    );
  }

  /// Outlined secondary action (e.g. View Location on church profile).
  factory PrimaryButton.outlinedAction({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    double? width,
    IconData? iconData,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isDisabled: isDisabled,
      backgroundColor: DarkTheme.feedCardBackground,
      borderColor: DarkTheme.feedMutedText.withValues(alpha: 0.35),
      textColor: Colors.white,
      radiusVariant: ButtonRadius.rounded,
      height: 44.h,
      paddingVertical: 12,
      paddingHorizontal: 12.w,
      width: width,
      fontSize: 14.sp,
      icon: iconData != null
          ? Icon(iconData, size: 18.r, color: Colors.white)
          : null,
    );
  }

  double _getRadius() {
    switch (radiusVariant) {
      case ButtonRadius.square:
        return 0;
      case ButtonRadius.rounded:
        return AppRadius.lg;
      case ButtonRadius.full:
        return AppRadius.circular;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isActuallyDisabled = isDisabled || isLoading;
    return GestureDetector(
      onTap: isActuallyDisabled ? null : onPressed,
      child: Opacity(
        opacity: isActuallyDisabled ? 0.5 : 1.0,
        child: Container(
          alignment: Alignment.center,
          height: height ?? 50.h,
          width: width,
          padding: EdgeInsets.symmetric(
            vertical: paddingVertical,
            horizontal: paddingHorizontal ?? 24.w,
          ),
          decoration: BoxDecoration(
            color: isGradient
                ? null
                : (backgroundColor ?? theme.colorScheme.primary),
            gradient: isGradient
                ? LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(_getRadius()),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      blurRadius: elevation,
                      offset: Offset(0, elevation / 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: (width?.isInfinite ?? false)
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? theme.colorScheme.onPrimary,
                    ),
                  ),
                )
              else if (icon != null || prefixIcon != null) ...[
                icon ?? prefixIcon!,
                AppSpacing.h8,
              ],
              if (!isLoading)
                Text(
                  text,
                  style: AppTextStyles.smMedium.copyWith(
                    color: textColor ?? theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              if ((trailingIcon != null || suffixIcon != null) &&
                  !isLoading) ...[
                AppSpacing.h8,
                trailingIcon ?? suffixIcon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
