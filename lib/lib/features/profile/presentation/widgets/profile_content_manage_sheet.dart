import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum ProfileContentManageAction { edit, delete }

enum ProfileContentKind { post, short, campaign, event }

/// Instagram-style action sheet for owned profile grid content.
Future<ProfileContentManageAction?> showProfileContentManageSheet(
  BuildContext context, {
  required ProfileContentKind kind,
}) {
  final colors = context.faithColors;
  final label = switch (kind) {
    ProfileContentKind.post => 'post',
    ProfileContentKind.short => 'short',
    ProfileContentKind.campaign => 'campaign',
    ProfileContentKind.event => 'event',
  };

  return showModalBottomSheet<ProfileContentManageAction>(
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
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Manage $label',
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              _ManageActionTile(
                icon: Iconsax.edit_2,
                label: 'Edit',
                onTap: () => Navigator.of(context)
                    .pop(ProfileContentManageAction.edit),
              ),
              _ManageActionTile(
                icon: Iconsax.trash,
                label: 'Delete',
                isDestructive: true,
                onTap: () => Navigator.of(context)
                    .pop(ProfileContentManageAction.delete),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> confirmProfileContentDelete(
  BuildContext context, {
  required ProfileContentKind kind,
}) async {
  final label = switch (kind) {
    ProfileContentKind.post => 'post',
    ProfileContentKind.short => 'short',
    ProfileContentKind.campaign => 'campaign',
    ProfileContentKind.event => 'event',
  };

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete $label?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  return confirmed == true;
}

Future<String?> showProfileContentEditSheet(
  BuildContext context, {
  required ProfileContentKind kind,
  required String initialText,
}) {
  final colors = context.faithColors;
  final label = switch (kind) {
    ProfileContentKind.post => 'post',
    ProfileContentKind.short => 'short',
    ProfileContentKind.campaign => 'campaign',
    ProfileContentKind.event => 'event',
  };
  final controller = TextEditingController(text: initialText);

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + bottomInset),
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
              'Edit $label',
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: kind == ProfileContentKind.post ? 6 : 3,
              minLines: kind == ProfileContentKind.post ? 4 : 2,
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 15.sp,
                height: 1.45,
              ),
              decoration: InputDecoration(
                hintText: kind == ProfileContentKind.post
                    ? 'Write your post...'
                    : 'Write a caption...',
                filled: true,
                fillColor: colors.tagBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: colors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: colors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: colors.brandBlue),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(context).pop(text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.brandBlue,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Save changes',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    },
  ).whenComplete(controller.dispose);
}

class _ManageActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ManageActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final color = isDestructive ? Colors.redAccent : colors.primaryText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, size: 22.r, color: color),
              SizedBox(width: 14.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
