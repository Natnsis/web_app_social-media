import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class LiveWatchActionRail extends StatelessWidget {
  final VoidCallback? onGift;
  final VoidCallback? onShare;

  const LiveWatchActionRail({
    super.key,
    this.onGift,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconCircleButton(
          icon: Iconsax.gift,
          size: 52,
          backgroundColor: DarkTheme.primary100,
          iconColor: DarkTheme.primary700,
          onPressed: onGift,
          tooltip: 'Send gift',
        ),
        SizedBox(height: 14.h),
        IconCircleButton(
          icon: Iconsax.share,
          size: 52,
          backgroundColor: Colors.black.withValues(alpha: 0.45),
          onPressed: onShare,
          tooltip: 'Share stream',
        ),
      ],
    );
  }
}
