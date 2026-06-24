import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_suggested_church.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DiscoverySuggestedCard extends StatelessWidget {
  final DiscoverySuggestedChurch church;
  final VoidCallback? onTap;

  const DiscoverySuggestedCard({
    super.key,
    required this.church,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final radius = BorderRadius.circular(20.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          width: 200.w,
          height: 220.h,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : colors.divider,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  church.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return ColoredBox(
                      color: colors.tagBackground,
                      child: Center(
                        child: SizedBox(
                          width: 28.r,
                          height: 28.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.brandBlue,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _ImageFallback(colors: colors),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: isDark ? 0.25 : 0.18),
                        Colors.black.withValues(alpha: isDark ? 0.82 : 0.72),
                      ],
                      stops: const [0.35, 0.62, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          church.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Iconsax.location,
                              size: 12.r,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                church.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12.sp,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final FaithAppColors colors;

  const _ImageFallback({required this.colors});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.tagBackground,
      child: Center(
        child: Icon(
          Iconsax.building_4,
          size: 40.r,
          color: colors.mutedText,
        ),
      ),
    );
  }
}
