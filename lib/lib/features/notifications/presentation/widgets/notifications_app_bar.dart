import 'dart:ui';



import 'package:faithconnect/core/theme/app_theme_extensions.dart';

import 'package:faithconnect/features/notifications/presentation/bloc/notifications_bloc.dart';

import 'package:faithconnect/features/notifications/presentation/bloc/notifications_event.dart';

import 'package:faithconnect/features/notifications/presentation/bloc/notifications_state.dart';

import 'package:faithconnect/features/notifications/presentation/pages/notification_preferences_page.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';



/// App bar wired to [NotificationsBloc] unread count and mark-all action.

class NotificationsAppBarHost extends StatelessWidget

    implements PreferredSizeWidget {

  const NotificationsAppBarHost({super.key});



  @override

  Size get preferredSize => Size.fromHeight(56.h);



  @override

  Widget build(BuildContext context) {

    return BlocBuilder<NotificationsBloc, NotificationsState>(

      buildWhen: (previous, current) =>

          previous.status != current.status ||

          previous.globalUnreadCount != current.globalUnreadCount,

      builder: (context, state) {

        final unread = state.globalUnreadCount;

        return NotificationsAppBar(

          unreadCount: unread,

          onBack: () => context.pop(),

          onMarkAllRead: unread > 0

              ? () => context

                  .read<NotificationsBloc>()

                  .add(const NotificationsMarkAllRead())

              : null,

        );

      },

    );

  }

}



class NotificationsAppBar extends StatelessWidget implements PreferredSizeWidget {

  static double topInset(BuildContext context) =>

      56.h + MediaQuery.paddingOf(context).top;



  final int unreadCount;

  final VoidCallback? onBack;

  final VoidCallback? onMarkAllRead;



  const NotificationsAppBar({

    super.key,

    this.unreadCount = 0,

    this.onBack,

    this.onMarkAllRead,

  });



  @override

  Size get preferredSize => Size.fromHeight(56.h);



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;

    final isDark = context.isDarkMode;

    final topPadding = MediaQuery.paddingOf(context).top;



    final bar = Container(

      height: preferredSize.height + topPadding,

      padding: EdgeInsets.only(top: topPadding),

      decoration: BoxDecoration(

        color: isDark

            ? colors.scaffoldBackground.withValues(alpha: 0.72)

            : colors.scaffoldBackground,

        border: Border(

          bottom: BorderSide(

            color: isDark

                ? colors.divider.withValues(alpha: 0.55)

                : colors.divider,

          ),

        ),

      ),

      child: Row(

        children: [

          IconButton(

            onPressed: onBack ?? () => Navigator.of(context).maybePop(),

            icon: Icon(

              CupertinoIcons.back,

              size: 22.r,

              color: colors.iconPrimary,

            ),

            tooltip: 'Back',

          ),

          Expanded(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  'Notifications',

                  style: GoogleFonts.inter(

                    color: colors.primaryText,

                    fontSize: 18.sp,

                    fontWeight: FontWeight.w700,

                    letterSpacing: -0.3,

                    height: 1.1,

                  ),

                ),

                if (unreadCount > 0)

                  Text(

                    '$unreadCount unread',

                    style: GoogleFonts.inter(

                      color: colors.brandSky.withValues(alpha: 0.9),

                      fontSize: 11.sp,

                      fontWeight: FontWeight.w500,

                    ),

                  ),

              ],

            ),

          ),

          if (unreadCount > 0 && onMarkAllRead != null)

            TextButton(

              onPressed: onMarkAllRead,

              style: TextButton.styleFrom(

                foregroundColor: colors.brandSky,

                padding: EdgeInsets.symmetric(horizontal: 12.w),

              ),

              child: Text(

                'Mark all',

                style: GoogleFonts.inter(

                  fontSize: 13.sp,

                  fontWeight: FontWeight.w600,

                ),

              ),

            ),

          IconButton(

            onPressed: () {

              Navigator.of(context).push(

                MaterialPageRoute(

                  builder: (_) => const NotificationPreferencesPage(),

                ),

              );

            },

            icon: Icon(

              Iconsax.setting_2,

              size: 22.r,

              color: colors.iconPrimary,

            ),

            tooltip: 'Settings',

          ),

        ],

      ),

    );



    if (!isDark) return bar;



    return ClipRect(

      child: BackdropFilter(

        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

        child: bar,

      ),

    );

  }

}


