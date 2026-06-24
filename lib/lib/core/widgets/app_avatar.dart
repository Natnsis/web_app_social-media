import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Avatar with optional online indicator and initials fallback.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final bool showOnline;
  final Color? borderColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 48,
    this.showOnline = false,
    this.borderColor,
  });

  static String initialsFromName(String? name) {
    final parts =
        name?.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty) ??
            const [];
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: size.r / 2,
        backgroundColor: DarkTheme.feedTagBackground,
        backgroundImage: NetworkImage(imageUrl!),
      );
    } else {
      final label = initials?.trim() ?? '';
      avatar = CircleAvatar(
        radius: size.r / 2,
        backgroundColor: DarkTheme.feedTagBackground,
        child: label.isNotEmpty
            ? Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: (size * 0.34).sp,
                ),
              )
            : Icon(
                Icons.person,
                color: Colors.white.withValues(alpha: 0.85),
                size: (size * 0.52).r,
              ),
      );
    }

    if (borderColor != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: 2),
        ),
        child: avatar,
      );
    }

    if (!showOnline) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12.r,
            height: 12.r,
            decoration: BoxDecoration(
              color: DarkTheme.chatOnlineIndicator,
              shape: BoxShape.circle,
              border: Border.all(
                color: DarkTheme.chatScaffoldBackground,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
