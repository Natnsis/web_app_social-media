import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Shared profile toolbar row (iOS back, title, optional theme/settings).
class ProfileHubToolbar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onTitleTap;
  final bool showTitleDropdown;
  final bool showThemeSwitch;
  final VoidCallback? onSettings;
  final List<Widget>? trailingActions;
  final bool centerTitle;
  final bool useWhiteInDarkMode;

  const ProfileHubToolbar({
    super.key,
    required this.title,
    this.onBack,
    this.onTitleTap,
    this.showTitleDropdown = false,
    this.showThemeSwitch = false,
    this.onSettings,
    this.trailingActions,
    this.centerTitle = false,
    this.useWhiteInDarkMode = false,
  });

  Color _iconColor(BuildContext context) {
    if (useWhiteInDarkMode && context.isDarkMode) {
      return Colors.white;
    }
    return context.primary;
  }

  Color _titleColor(BuildContext context, FaithAppColors colors) {
    if (useWhiteInDarkMode && context.isDarkMode) {
      return Colors.white;
    }
    return colors.headerTitle;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final iconColor = _iconColor(context);

    if (centerTitle) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: SizedBox(
          height: 48.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (onBack != null)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: iconColor,
                        size: 20.sp,
                      ),
                      onPressed: onBack,
                      visualDensity: VisualDensity.compact,
                    )
                  else
                    SizedBox(width: 48.w),
                  _buildTrailing(context, iconColor),
                ],
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 108.w),
                  child: Center(
                    child: _buildTitle(context, colors),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: iconColor,
                size: 20.sp,
              ),
              onPressed: onBack,
              visualDensity: VisualDensity.compact,
            )
          else
            SizedBox(width: 48.w),
          Expanded(child: _buildTitle(context, colors)),
          _buildTrailing(context, iconColor),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, FaithAppColors colors) {
    final titleStyle = GoogleFonts.inter(
      color: _titleColor(context, colors),
      fontSize: showTitleDropdown ? 16.sp : 20.sp,
      fontWeight: showTitleDropdown ? FontWeight.w600 : FontWeight.w700,
    );

    if (showTitleDropdown && onTitleTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTitleTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _titleColor(context, colors),
                  size: 22.r,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      style: titleStyle,
    );
  }

  Widget _buildTrailing(BuildContext context, Color iconColor) {
    if (trailingActions != null && trailingActions!.isNotEmpty) {
      return Row(mainAxisSize: MainAxisSize.min, children: trailingActions!);
    }

    if (!showThemeSwitch && onSettings == null) {
      return SizedBox(width: 48.w);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showThemeSwitch) const AppThemeModeSwitch(),
        if (showThemeSwitch && onSettings != null) SizedBox(width: 2.w),
        if (onSettings != null)
          IconButton(
            icon: Icon(
              Iconsax.setting_2,
              color: iconColor,
              size: 22.r,
            ),
            onPressed: onSettings,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

/// Standard profile sub-page app bar (settings, gifts, analytics, etc.).
class ProfileHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showThemeSwitch;
  final VoidCallback? onSettings;
  final List<Widget>? actions;
  final bool useWhiteInDarkMode;

  const ProfileHubAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showThemeSwitch = false,
    this.onSettings,
    this.actions,
    this.useWhiteInDarkMode = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppBar(
      backgroundColor: colors.scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: context.faithStatusBarOverlay,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      leadingWidth: 0,
      titleSpacing: 0,
      title: ProfileHubToolbar(
        title: title,
        onBack: onBack ?? () => context.pop(),
        showThemeSwitch: showThemeSwitch,
        onSettings: onSettings,
        trailingActions: actions,
        useWhiteInDarkMode: useWhiteInDarkMode,
      ),
    );
  }
}
