import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMoreMenuOption<T> {
  final T value;
  final IconData icon;
  final String label;
  final bool isDestructive;

  const ChatMoreMenuOption({
    required this.value,
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });
}

/// Anchored popup menu shown below the top-right of the chat screen.
Future<T?> showChatMoreOptionsMenu<T>({
  required BuildContext context,
  required List<ChatMoreMenuOption<T>> options,
  double? topInset,
  double menuWidth = 228,
}) {
  if (options.isEmpty) return Future.value();

  final colors = context.faithColors;
  final media = MediaQuery.of(context);
  final resolvedTop = topInset ?? media.padding.top + kToolbarHeight + 8.h;
  final horizontalInset = 12.w;

  return showMenu<T>(
    context: context,
    color: colors.cardBackground,
    elevation: 10,
    shadowColor: Colors.black.withValues(alpha: 0.18),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.r),
      side: BorderSide(color: colors.divider.withValues(alpha: 0.35)),
    ),
    position: RelativeRect.fromLTRB(
      media.size.width - menuWidth - horizontalInset,
      resolvedTop,
      horizontalInset,
      0,
    ),
    items: options
        .map(
          (option) => PopupMenuItem<T>(
            value: option.value,
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _ChatMoreMenuRow(option: option),
          ),
        )
        .toList(),
  );
}

double chatDetailMoreMenuTopInset(
  BuildContext context, {
  bool hasActionBar = false,
}) {
  var top = MediaQuery.paddingOf(context).top + kToolbarHeight + 8.h;
  if (hasActionBar) {
    top += 44.h;
  }
  return top;
}

/// Group detail sheet: app bar below safe area.
double groupDetailMoreMenuTopInset(BuildContext context) {
  return MediaQuery.paddingOf(context).top + 56.h + 8.h;
}

/// Direct chat detail sheet: app bar + action row.
double directChatDetailMoreMenuTopInset(BuildContext context) {
  return MediaQuery.paddingOf(context).top + 56.h + 44.h + 8.h;
}

class _ChatMoreMenuRow extends StatelessWidget {
  final ChatMoreMenuOption<dynamic> option;

  const _ChatMoreMenuRow({required this.option});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final foreground =
        option.isDestructive ? Colors.red.shade400 : colors.primaryText;
    final iconColor =
        option.isDestructive ? Colors.red.shade400 : colors.brandBlue;

    return Row(
      children: [
        Icon(option.icon, size: 18.r, color: iconColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            option.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: foreground,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
