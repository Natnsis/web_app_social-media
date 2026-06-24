import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum ChatInboxFilter { all, unread, muted }

Future<ChatInboxFilter?> showChatListFilterSheet(
  BuildContext context, {
  required ChatInboxFilter selected,
}) {
  final colors = context.faithColors;

  return showModalBottomSheet<ChatInboxFilter>(
    context: context,
    backgroundColor: colors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Filter chats',
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              _FilterTile(
                icon: Iconsax.element_3,
                label: 'All chats',
                selected: selected == ChatInboxFilter.all,
                onTap: () => Navigator.pop(context, ChatInboxFilter.all),
              ),
              _FilterTile(
                icon: Iconsax.notification,
                label: 'Unread',
                selected: selected == ChatInboxFilter.unread,
                onTap: () => Navigator.pop(context, ChatInboxFilter.unread),
              ),
              _FilterTile(
                icon: Iconsax.notification_status,
                label: 'Muted',
                selected: selected == ChatInboxFilter.muted,
                onTap: () => Navigator.pop(context, ChatInboxFilter.muted),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FilterTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: selected ? colors.brandBlue : colors.mutedText,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: selected ? colors.brandBlue : colors.primaryText,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: colors.brandBlue, size: 22.r)
          : null,
    );
  }
}
