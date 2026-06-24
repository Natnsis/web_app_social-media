import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/presentation/widgets/direct_chat_info_sheet.dart';
import 'package:flutter/material.dart';

abstract final class DirectChatNavigation {
  DirectChatNavigation._();

  static Future<DirectChatInfoResult?> showInfoSheet(
    BuildContext context, {
    required ChatRoom room,
    required bool isMuted,
  }) {
    return Navigator.of(context).push<DirectChatInfoResult>(
      MaterialPageRoute(
        builder: (_) => DirectChatInfoSheet(
          room: room,
          initialMuted: isMuted,
        ),
      ),
    );
  }
}
