import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Top quick actions on group detail: mute, manage, leave, more.
class GroupDetailActionsBar extends StatelessWidget {
  final bool isMuted;
  final bool showManage;
  final VoidCallback? onMuteTap;
  final VoidCallback? onManageTap;
  final VoidCallback? onLeaveTap;

  const GroupDetailActionsBar({
    super.key,
    this.isMuted = false,
    this.showManage = true,
    this.onMuteTap,
    this.onManageTap,
    this.onLeaveTap,
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              _QuickAction(
                icon: isMuted ? Iconsax.notification_status : Iconsax.notification,
                label: isMuted ? 'Unmute' : 'Mute',
                isActive: isMuted,
                onTap: onMuteTap,
              ),
              _Divider(color: colors.divider),
              if (showManage) ...[
                _QuickAction(
                  icon: Iconsax.setting_2,
                  label: 'Manage',
                  onTap: onManageTap,
                ),
                _Divider(color: colors.divider),
              ],
              _QuickAction(
                icon: Iconsax.logout,
                label: 'Leave',
                isDestructive: true,
                onTap: onLeaveTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        '│',
        style: GoogleFonts.inter(
          color: color.withValues(alpha: 0.45),
          fontSize: 14.sp,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isDestructive;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final foreground = isDestructive
        ? Colors.red.shade400
        : (isActive ? colors.brandBlue : colors.primaryText);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17.r, color: foreground),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: foreground,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
