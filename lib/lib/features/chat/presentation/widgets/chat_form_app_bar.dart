import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
class ChatFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ChatFormAppBar({super.key, required this.title});

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
      leading: IconButton(
        icon: Icon(CupertinoIcons.back, color: colors.iconPrimary, size: 22.r),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: colors.headerTitle,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }
}
