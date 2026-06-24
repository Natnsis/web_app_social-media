import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/domain/home_shell_account_mode.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_scope.dart';
import 'package:faithconnect/features/home/presentation/widgets/account_mode_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet to switch church vs member account view (prefs-backed).
class AccountModeSwitchSheet extends StatelessWidget {
  const AccountModeSwitchSheet({super.key});

  static Future<void> show(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          isDark ? DarkTheme.feedCardBackground : colors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const AccountModeSwitchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shellMode = HomeShellModeScope.of(context);
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final titleColor = isDark ? Colors.white : colors.primaryText;
    final subtitleColor =
        isDark ? DarkTheme.feedMutedText : colors.mutedText;
    final handleColor = isDark
        ? DarkTheme.feedMutedText.withValues(alpha: 0.4)
        : colors.mutedText.withValues(alpha: 0.35);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: ListenableBuilder(
          listenable: shellMode,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Account view',
                  style: GoogleFonts.inter(
                    color: titleColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  shellMode.roleLabel,
                  style: GoogleFonts.inter(
                    color: subtitleColor,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                if (shellMode.canSwitchAccountMode)
                  AccountModeSwitcher(
                    mode: shellMode.mode,
                    showDescription: true,
                    onModeChanged: (HomeShellAccountMode mode) {
                      shellMode.setMode(mode);
                    },
                  )
                else
                  Text(
                    'Community members browse content and saved posts. '
                    'Church publishing tools are not available for this account.',
                    style: GoogleFonts.inter(
                      color: subtitleColor,
                      fontSize: 13.sp,
                      height: 1.45,
                    ),
                  ),
                SizedBox(height: 16.h),
                PrimaryButton.feedAction(
                  text: 'Done',
                  onPressed: () => Navigator.of(context).pop(),
                  width: double.infinity,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
