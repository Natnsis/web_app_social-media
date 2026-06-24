import 'package:faithconnect/features/chat/domain/entities/chat_message_delivery_status.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/core/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// WhatsApp / Telegram-style ticks for outgoing messages.
class ChatReadReceiptIcon extends StatelessWidget {
  final ChatMessageDeliveryStatus status;
  final Color color;
  final List<ChatMessageSeenReceipt>? receipts;

  const ChatReadReceiptIcon({
    super.key,
    required this.status,
    required this.color,
    this.receipts,
  });

  void _showSeenByDialog(BuildContext context) {
    if (receipts == null || receipts!.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seen by'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: receipts!.length,
              itemBuilder: (context, index) {
                final receipt = receipts![index];
                return ListTile(
                  leading: AppAvatar(
                    imageUrl: receipt.avatarUrl,
                    initials: AppAvatar.initialsFromName(receipt.fullName),
                    size: 40,
                  ),
                  title: Text(receipt.fullName),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = switch (status) {
      ChatMessageDeliveryStatus.sending => Icon(
          Icons.access_time_rounded,
          size: 14.r,
          color: color.withValues(alpha: 0.7),
        ),
      ChatMessageDeliveryStatus.sent => Text(
          '✓',
          style: TextStyle(
            color: color.withValues(alpha: 0.75),
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ChatMessageDeliveryStatus.read => Text(
          '✓✓',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),
    };

    if (status == ChatMessageDeliveryStatus.read && receipts != null && receipts!.isNotEmpty) {
      return GestureDetector(
        onTap: () => _showSeenByDialog(context),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: icon,
        ),
      );
    }

    return icon;
  }
}
