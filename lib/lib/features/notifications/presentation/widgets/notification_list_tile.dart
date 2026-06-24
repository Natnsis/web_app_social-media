import 'dart:ui';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotificationListTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationListTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final isUnread = !notification.isRead;
    final accent = _categoryAccent(notification.category, colors);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.betweenListItems),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: isUnread && isDark
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.55),
                      colors.brandBlue.withValues(alpha: 0.35),
                      DarkTheme.accent500.withValues(alpha: 0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.10),
                      blurRadius: 8,
                      spreadRadius: -6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : isUnread
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: colors.brandSky.withValues(alpha: 0.35),
                      ),
                    )
                  : null,
          padding: isUnread && isDark ? EdgeInsets.all(1.2.r) : EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19.r),
            child: _themedTileCard(
              isDark: isDark,
              colors: colors,
              isUnread: isUnread,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GlowingAvatar(
                    imageUrl: notification.actorAvatarUrl,
                    initials: notification.actorName.isNotEmpty
                        ? notification.actorName[0]
                        : '?',
                    accent: accent,
                    isUnread: isUnread,
                    category: notification.category,
                  ),
                  SizedBox(width: AppSpacing.baseUnit.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: colors.primaryText,
                                  fontSize: 14.sp,
                                  fontWeight: isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            Text(
                              formatShortTimeAgo(notification.createdAt),
                              style: GoogleFonts.inter(
                                color: isUnread
                                    ? colors.brandSky
                                    : colors.mutedText,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.v4,
                        RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              color: colors.mutedText,
                              fontSize: 13.sp,
                              height: 1.35,
                            ),
                            children: [
                              TextSpan(
                                text: notification.actorName,
                                style: TextStyle(
                                  color: colors.primaryText
                                      .withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' ${notification.body}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (notification.previewImageUrl != null) ...[
                    SizedBox(width: 10.w),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        notification.previewImageUrl!,
                        width: 48.r,
                        height: 48.r,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _PreviewFallback(accent: accent),
                      ),
                    ),
                  ] else if (isUnread) ...[
                    SizedBox(width: 8.w),
                    Container(
                      width: 8.r,
                      height: 8.r,
                      margin: EdgeInsets.only(top: 6.h),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accent, colors.brandBlue],
                        ),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _themedTileCard({
    required bool isDark,
    required FaithAppColors colors,
    required bool isUnread,
    required Widget child,
  }) {
    final card = Container(
      padding: AppSpacing.listItemPadding,
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark
                ? const Color(0xFF121824).withValues(alpha: 0.88)
                : colors.brandSky.withValues(alpha: 0.08))
            : (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : colors.tagBackground),
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(
          color: isUnread
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : colors.brandSky.withValues(alpha: 0.2))
              : (isDark
                  ? DarkTheme.authCardBorder.withValues(alpha: 0.4)
                  : colors.divider),
        ),
      ),
      child: child,
    );

    if (!isDark) return card;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: card,
    );
  }

  static Color _categoryAccent(
    NotificationCategory category,
    FaithAppColors colors,
  ) {
    return switch (category) {
      NotificationCategory.live => DarkTheme.feedLiveGradientStart,
      NotificationCategory.like => DarkTheme.primary400,
      NotificationCategory.comment => colors.brandSky,
      NotificationCategory.follow => DarkTheme.accent400,
      NotificationCategory.campaign => DarkTheme.feedEventLabel,
      NotificationCategory.mention => DarkTheme.accent500,
      NotificationCategory.message => DarkTheme.primary400,
      NotificationCategory.system => DarkTheme.secondary400,
    };
  }
}

class _GlowingAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final Color accent;
  final bool isUnread;
  final NotificationCategory category;

  const _GlowingAvatar({
    required this.imageUrl,
    required this.initials,
    required this.accent,
    required this.isUnread,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.all(isUnread ? 2.2.r : 1.5.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUnread
            ? LinearGradient(
                colors: [accent, colors.brandBlue, DarkTheme.accent500],
              )
            : LinearGradient(
                colors: [
                  isDark ? DarkTheme.authCardBorder : colors.divider,
                  (isDark ? DarkTheme.authCardBorder : colors.divider)
                      .withValues(alpha: 0.5),
                ],
              ),
        boxShadow: isUnread && isDark
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AppAvatar(
            imageUrl: imageUrl,
            size: 44,
            initials: initials,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18.r,
              height: 18.r,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0E1218)
                    : colors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? DarkTheme.authCardBorder : colors.divider,
                  width: 1.2,
                ),
              ),
              child: Icon(
                _categoryIcon(category),
                size: 10.r,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _categoryIcon(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.live => Iconsax.video_play,
      NotificationCategory.like => Iconsax.heart,
      NotificationCategory.comment => Iconsax.message,
      NotificationCategory.follow => Iconsax.user_add,
      NotificationCategory.campaign => Iconsax.money_recive,
      NotificationCategory.mention => Iconsax.tag_user,
      NotificationCategory.message => Iconsax.direct_inbox,
      NotificationCategory.system => Iconsax.notification,
    };
  }
}

class _PreviewFallback extends StatelessWidget {
  final Color accent;

  const _PreviewFallback({required this.accent});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.35),
            colors.brandBlue.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Icon(Iconsax.gallery, size: 18.r, color: accent),
    );
  }
}
