import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/domain/entities/featured_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeaturedEventCard extends StatelessWidget {
  final FeaturedEvent event;

  const FeaturedEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: AppRadius.large,
        border: isDark ? null : Border.all(color: colors.divider),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FEATURED EVENT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFFF9F43),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  event.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  event.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.mutedText,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
                _EventDetailRow(
                  icon: Icons.calendar_today_outlined,
                  text: event.dateTime,
                ),
                SizedBox(height: 8.h),
                _EventDetailRow(
                  icon: Icons.location_on_outlined,
                  text: event.location,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (event.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                event.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colors.tagBackground,
                  child: Icon(
                    Icons.image_outlined,
                    color: colors.mutedText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.faithColors;

    return Row(
      children: [
        Icon(icon, size: 16.r, color: colors.brandSky),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.mutedText,
            ),
          ),
        ),
      ],
    );
  }
}
