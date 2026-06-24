import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_live_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DiscoveryLiveCard extends StatelessWidget {
  final DiscoveryLiveItem item;
  final VoidCallback? onTap;

  const DiscoveryLiveCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: SizedBox(
          width: 168.w,
          height: 240.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (item.thumbnailUrl != null)
                Image.network(
                  item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _Fallback(),
                )
              else
                const _Fallback(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const LiveIndicatorBadge(compact: true),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: GlassInfoPill(
                            leading: Icon(
                              Iconsax.eye,
                              color: Colors.white,
                              size: 14.r,
                            ),
                            text: '${formatCount(item.viewerCount)} watching',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.organizationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return ColoredBox(
      color: colors.tagBackground,
      child: Center(
        child: Icon(
          Iconsax.video_play,
          color: colors.mutedText.withValues(alpha: 0.5),
          size: 48,
        ),
      ),
    );
  }
}
