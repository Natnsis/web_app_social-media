import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class LiveWatchTopBar extends StatelessWidget {
  final LiveStream stream;
  final VoidCallback? onClose;

  const LiveWatchTopBar({
    super.key,
    required this.stream,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Row(
        children: [
          const LiveIndicatorBadge(pulse: true),
          SizedBox(width: 10.w),
          GlassInfoPill(
            leading: Icon(
              Iconsax.eye,
              color: Colors.white,
              size: 16.r,
            ),
            text: '${formatCount(stream.viewerCount)} watching',
          ),
          const Spacer(),
          if (onClose != null)
            IconCircleButton(
              icon: Iconsax.close_circle,
              backgroundColor: Colors.black.withValues(alpha: 0.45),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}
