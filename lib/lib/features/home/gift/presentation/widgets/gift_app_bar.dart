import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gift header with iOS-style back and adaptive theme colors.
class GiftAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GiftAppBar({super.key, required this.title});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final brandBlue = context.faithColors.brandBlue;
    final backgroundColor = isDark ? colors.cardBackground : brandBlue;
    final foregroundColor = isDark ? colors.primaryText : Colors.white;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.light,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.dark,
    );

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: overlayStyle,
      leading: IconButton(
        icon: Icon(CupertinoIcons.back, color: foregroundColor, size: 22.r),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: foregroundColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }
}
