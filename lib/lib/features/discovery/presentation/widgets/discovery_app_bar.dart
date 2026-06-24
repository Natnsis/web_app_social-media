import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DiscoveryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showMenu;
  final bool showSearch;
  final bool showNotifications;
  final Color? iconColor;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final List<Widget>? trailingActions;

  const DiscoveryAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.showMenu = false,
    this.showSearch = false,
    this.showNotifications = false,
    this.iconColor,
    this.onMenuTap,
    this.onSearchTap,
    this.onNotificationsTap,
    this.trailingActions,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final effectiveIconColor = iconColor ?? colors.iconPrimary;

    return AppBar(
      backgroundColor: colors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: context.faithStatusBarOverlay,
      leading: showBack
          ? IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: effectiveIconColor,
                size: 22.r,
              ),
              onPressed: () => context.pop(),
            )
          : showMenu
              ? IconButton(
                  icon: Icon(Iconsax.menu, color: effectiveIconColor, size: 24.r),
                  onPressed: onMenuTap,
                )
              : null,
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: colors.headerTitle,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [
        if (showSearch)
          IconButton(
            icon: Icon(
              Iconsax.search_normal,
              color: effectiveIconColor,
              size: 22.r,
            ),
            onPressed: onSearchTap,
          ),
        if (showNotifications)
          IconButton(
            icon: Icon(
              Iconsax.notification,
              color: effectiveIconColor,
              size: 22.r,
            ),
            onPressed: onNotificationsTap,
          ),
        ...?trailingActions,
      ],
    );
  }
}
