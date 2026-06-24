import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Shows a manage action for comments/reflections owned by the current user.
Future<String?> showOwnedCommentManageMenu(
  BuildContext context, {
  required Offset globalPosition,
  String deleteLabel = 'Delete',
  String editLabel = 'Edit',
}) async {
  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      globalPosition.dx + 1,
      globalPosition.dy + 1,
    ),
    items: [
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.edit_2, size: 18.r),
            SizedBox(width: 10.w),
            Text(editLabel),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.trash, size: 18.r),
            SizedBox(width: 10.w),
            Text(deleteLabel),
          ],
        ),
      ),
    ],
  );

  return selected;
}

/// Shows a positioned popup menu with:
/// - Reply (always visible)
/// - Edit + Delete (only when [isOwned] is true)
///
/// Returns the selected action key: `'reply'`, `'edit'`, or `'delete'`.
Future<String?> showCommentActionMenu(
  BuildContext context, {
  required Offset globalPosition,
  required bool isOwned,
  String replyLabel = 'Reply',
  String editLabel = 'Edit',
  String deleteLabel = 'Delete',
}) async {
  final rect = RelativeRect.fromLTRB(
    globalPosition.dx,
    globalPosition.dy,
    globalPosition.dx + 1,
    globalPosition.dy + 1,
  );

  final items = <PopupMenuEntry<String>>[
    PopupMenuItem<String>(
      value: 'reply',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.arrow_left_2, size: 16.r),
          SizedBox(width: 10.w),
          Text(replyLabel),
        ],
      ),
    ),
    if (isOwned) ...[
      const PopupMenuDivider(height: 1),
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.edit_2, size: 16.r),
            SizedBox(width: 10.w),
            Text(editLabel),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.trash, size: 16.r, color: Colors.redAccent),
            SizedBox(width: 10.w),
            Text(
              deleteLabel,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    ],
  ];

  return showMenu<String>(
    context: context,
    position: rect,
    items: items,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    elevation: 4,
  );
}
