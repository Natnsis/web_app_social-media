import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:faithconnect/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const NotificationPreferencesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.faithColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: context.faithColors.scaffoldBackground,
        elevation: 0,
        systemOverlayStyle: context.faithStatusBarOverlay,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: context.faithColors.iconPrimary,
            size: 22.r,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notification Settings',
          style: GoogleFonts.inter(
            color: context.faithColors.primaryText,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final prefs = state.preferences;
          if (prefs == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive alerts on your device',
                value: prefs.pushNotifications,
                onChanged: (val) {
                  context.read<NotificationsBloc>().add(
                        NotificationPreferencesUpdated(pushNotifications: val),
                      );
                },
              ),
              AppSpacing.v16,
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Receive daily summaries and important updates',
                value: prefs.emailNotifications,
                onChanged: (val) {
                  context.read<NotificationsBloc>().add(
                        NotificationPreferencesUpdated(emailNotifications: val),
                      );
                },
              ),
              AppSpacing.v16,
              _buildSwitchTile(
                title: 'SMS Notifications',
                subtitle: 'Receive text messages for urgent alerts',
                value: prefs.smsNotifications,
                onChanged: (val) {
                  context.read<NotificationsBloc>().add(
                        NotificationPreferencesUpdated(smsNotifications: val),
                      );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13171F) : colors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? DarkTheme.authCardBorder.withValues(alpha: 0.5)
              : colors.divider,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            color: colors.mutedText,
            fontSize: 13.sp,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: colors.brandSky,
      ),
    );
  }
}
