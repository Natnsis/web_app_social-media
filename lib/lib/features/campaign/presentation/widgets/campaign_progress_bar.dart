import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CampaignProgressBar extends StatelessWidget {
  final double progress;
  final double height;

  const CampaignProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final value = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: SizedBox(
        height: height.h,
        child: LinearProgressIndicator(
          value: value,
          minHeight: height.h,
          backgroundColor: colors.tagBackground,
          color: colors.brandBlue,
        ),
      ),
    );
  }
}
