import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final bool searchActive;
  final bool filterActive;

  const ChatListAppBar({
    super.key,
    this.onMenuTap,
    this.onSearchTap,
    this.onFilterTap,
    this.searchActive = false,
    this.filterActive = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final iconColor = colors.iconMuted;

    return AppBar(
      backgroundColor: colors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: context.faithStatusBarOverlay,
      iconTheme: IconThemeData(color: iconColor),
      actionsIconTheme: IconThemeData(color: iconColor),
      leading: IconButton(
        icon: Icon(Iconsax.menu, color: iconColor),
        onPressed: onMenuTap,
      ),
      title: Text(
        'Chat',
        style: GoogleFonts.inter(
          color: colors.headerTitle,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            searchActive ? Iconsax.close_circle : Iconsax.search_normal,
            color: searchActive ? colors.brandBlue : iconColor,
          ),
          tooltip: searchActive ? 'Close search' : 'Search',
          onPressed: onSearchTap,
        ),
        IconButton(
          icon: Icon(
            Iconsax.setting_4,
            color: filterActive ? colors.brandBlue : iconColor,
          ),
          tooltip: 'Filter',
          onPressed: onFilterTap,
        ),
      ],
    );
  }
}
