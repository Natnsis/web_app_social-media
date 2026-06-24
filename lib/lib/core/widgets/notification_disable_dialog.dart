import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../core.dart';

class NotificationDisableDialog extends StatelessWidget {
  final VoidCallback onConfirm; // Callback to disable
  final VoidCallback? onCancel; // Callback to keep enabled

  const NotificationDisableDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) => NotificationDisableDialog(
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.r),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF0F1115) : Colors.white,
      elevation: 24,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing bell and slash illustration
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric circles/halos
                    Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: BoxDecoration(
                        color: colors.brandBlue.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        color: colors.brandBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.error.withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.notification_status_copy,
                        size: 30.r,
                        color: colors.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                
                // Title
                Text(
                  'Silence Notifications?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 8.h),
                
                // Subtitle
                Text(
                  'Disabling notifications means you will miss key moments and updates from your church community.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: colors.mutedText,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 20.h),

                // "What you'll miss" Section Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? colors.tagBackground.withValues(alpha: 0.4)
                        : colors.tagBackground.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildMissedItem(
                        context,
                        icon: Iconsax.notification_bing_copy,
                        iconColor: colors.brandBlue,
                        title: 'Important Updates',
                        subtitle: 'Urgent announcements and posts from pastors.',
                      ),
                      Divider(
                        color: colors.divider.withValues(alpha: 0.5),
                        height: 20.h,
                        thickness: 1,
                      ),
                      _buildMissedItem(
                        context,
                        icon: Iconsax.calendar_1_copy,
                        iconColor: const Color(0xFF9D59EF),
                        title: 'Event Invitations',
                        subtitle: 'Service changes, church invites & schedules.',
                      ),
                      Divider(
                        color: colors.divider.withValues(alpha: 0.5),
                        height: 20.h,
                        thickness: 1,
                      ),
                      _buildMissedItem(
                        context,
                        icon: Iconsax.message_copy,
                        iconColor: const Color(0xFF10B981),
                        title: 'Community Interaction',
                        subtitle: 'Replies, messages and connections from members.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Buttons
                Column(
                  children: [
                    // Keep Active Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.brandBlue,
                            colors.brandSky,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: colors.brandBlue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (onCancel != null) onCancel!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          'Keep Notifications Active',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Silence Anyway button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          'Silence Anyway',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissedItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final colors = context.faithColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18.r,
            color: iconColor,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryText,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w400,
                  color: colors.mutedText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
