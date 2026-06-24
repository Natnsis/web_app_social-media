import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:faithconnect/core/widgets/count_badge.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;

  const HomeAppBar({
    super.key,
    this.onMenuTap,
    this.onSearchTap,
    this.onNotificationsTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final iconColor = colors.iconPrimary;
    final actionIconColor =
        context.isDarkMode ? colors.iconPrimary : colors.iconMuted;

    return AppBar(
      backgroundColor: colors.scaffoldBackground,
      foregroundColor: iconColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: context.faithStatusBarOverlay,
      iconTheme: IconThemeData(color: iconColor),
      actionsIconTheme: IconThemeData(color: actionIconColor),
      leading: IconButton(
        icon: Icon(Iconsax.menu, color: iconColor),
        onPressed: onMenuTap,
        tooltip: 'Menu',
      ),
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
          children: [
            TextSpan(
              text: 'Faith',
              style: TextStyle(color: colors.primaryText),
            ),
            TextSpan(
              text: 'Connect',
              style: TextStyle(color: colors.brandSky),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Iconsax.search_normal, color: actionIconColor),
          onPressed: onSearchTap,
          tooltip: 'Search',
        ),
        BlocBuilder<NotificationsBloc, NotificationsState>(
          buildWhen: (previous, current) => previous.globalUnreadCount != current.globalUnreadCount,
          builder: (context, state) {
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Iconsax.notification, color: actionIconColor),
                  onPressed: onNotificationsTap,
                  tooltip: 'Notifications',
                ),
                if (state.globalUnreadCount > 0)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: CountBadge(count: state.globalUnreadCount),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
