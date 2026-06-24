import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EventCard extends StatelessWidget {
  final ChurchEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final churchName = event.churchName?.trim() ?? 'Church event';

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
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
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 0),
            child: Row(
              children: [
                InkWell(
                  onTap: event.churchId != null
                      ? () => context.pushNamed(
                            RoutesConstant.churchProfile,
                            pathParameters: {'id': event.churchId!},
                          )
                      : null,
                  borderRadius: BorderRadius.circular(999),
                  child: AppAvatar(
                    initials: _initialsFor(churchName),
                    size: 40,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: InkWell(
                    onTap: event.churchId != null
                        ? () => context.pushNamed(
                              RoutesConstant.churchProfile,
                              pathParameters: {'id': event.churchId!},
                            )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          churchName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          event.dateTimeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F43).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'EVENT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFF9F43),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
            child: Text(
              event.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (event.description.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 0),
              child: Text(
                event.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.primaryText.withValues(alpha: 0.92),
                  height: 1.45,
                ),
              ),
            ),
          if (event.imageUrl != null) ...[
            SizedBox(height: 12.h),
            AspectRatio(
              aspectRatio: 16 / 9,
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
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Row(
              children: [
                Icon(Iconsax.calendar, size: 18.r, color: colors.brandSky),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    event.dateTimeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.mutedText,
                    ),
                  ),
                ),
                if (event.location.trim().isNotEmpty) ...[
                  Icon(Iconsax.location, size: 18.r, color: colors.brandSky),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.mutedText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final list = parts.toList();
    if (list.isEmpty) return '?';
    if (list.length == 1) {
      return list.first[0].toUpperCase();
    }
    return '${list.first[0]}${list[1][0]}'.toUpperCase();
  }
}
