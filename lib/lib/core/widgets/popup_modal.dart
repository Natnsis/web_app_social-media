import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:faithconnect/core/constants/spacing_radius.dart';
import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/theme/app_text_styles.dart';
import 'package:faithconnect/core/widgets/primary_button.dart';

class PopupModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool isButtonLoading;
  final bool isSuccess;
  final IconData? icon;

  const PopupModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
    this.isButtonLoading = false,
    this.isSuccess = true,
    this.icon,
  });

  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool isSuccess = true,
    IconData? icon,
    bool isButtonLoading = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopupModal(
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        isSuccess: isSuccess,
        icon: icon,
        isButtonLoading: isButtonLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayIcon = icon ?? (isSuccess ? Icons.check_circle : Icons.error);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.extraLarge),
      backgroundColor: colorScheme.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              displayIcon,
              size: 64.r,
              color: isSuccess ? colorScheme.success500 : colorScheme.error500,
            ),
            AppSpacing.v16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.xlBold.copyWith(color: colorScheme.primary950),
            ),
            if (subtitle != null) ...[
              AppSpacing.v8,
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.smRegular.copyWith(
                  color: colorScheme.secondary,
                  height: 1.4,
                ),
              ),
            ],
            AppSpacing.v24,
            PrimaryButton(
              isLoading: isButtonLoading,
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Navigator.pop(context);
                onButtonPressed();
              },
              text: buttonText,
            ),
          ],
        ),
      ),
    );
  }
}
