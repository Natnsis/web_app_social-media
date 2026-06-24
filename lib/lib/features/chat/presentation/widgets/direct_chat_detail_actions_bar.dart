import 'package:faithconnect/core/core.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';



/// Quick actions on direct chat detail: message, call, mute, more (icons only).

class DirectChatDetailActionsBar extends StatelessWidget {

  final bool isMuted;

  final VoidCallback? onMessageTap;

  final VoidCallback? onCallTap;

  final VoidCallback? onMuteTap;

  final VoidCallback? onMoreTap;



  const DirectChatDetailActionsBar({

    super.key,

    this.isMuted = false,

    this.onMessageTap,

    this.onCallTap,

    this.onMuteTap,

    this.onMoreTap,

  });



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;



    return Material(

      color: colors.scaffoldBackground,

      child: DecoratedBox(

        decoration: BoxDecoration(

          border: Border(

            bottom: BorderSide(color: colors.divider.withValues(alpha: 0.45)),

          ),

        ),

        child: Padding(

          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),

          child: Row(

            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [

              _QuickActionIcon(

                icon: Iconsax.message,

                tooltip: 'Message',

                isActive: true,

                onTap: onMessageTap,

              ),

              _QuickActionIcon(

                icon: Iconsax.call,

                tooltip: 'Call',

                onTap: onCallTap,

              ),

              _QuickActionIcon(

                icon: isMuted

                    ? Iconsax.notification_status

                    : Iconsax.notification,

                tooltip: isMuted ? 'Unmute' : 'Mute',

                isActive: isMuted,

                onTap: onMuteTap,

              ),

            ],

          ),

        ),

      ),

    );

  }

}



class _QuickActionIcon extends StatelessWidget {

  final IconData icon;

  final String tooltip;

  final VoidCallback? onTap;

  final bool isActive;



  const _QuickActionIcon({

    required this.icon,

    required this.tooltip,

    this.onTap,

    this.isActive = false,

  });



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;

    final foreground = isActive ? colors.brandBlue : colors.iconPrimary;



    return IconCircleButton(

      icon: icon,

      tooltip: tooltip,

      onPressed: onTap,

      iconColor: foreground,

      size: 40,

    );

  }

}


