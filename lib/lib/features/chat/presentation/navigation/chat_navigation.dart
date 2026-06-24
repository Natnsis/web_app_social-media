import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/application/chat_service.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_event.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract final class ChatNavigation {
  ChatNavigation._();

  static Future<void> openDirectChat({
    required BuildContext context,
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) async {
    final peerId = userId.trim();
    if (peerId.isEmpty) return;

    final currentUserId = await SharedPrefsService.getUserId();
    if (!context.mounted) return;

    if (currentUserId != null && currentUserId.trim() == peerId) {
      showInfo(context, 'You cannot message yourself.');
      return;
    }

    final cachedRooms = context.read<ChatBloc>().cachedRooms;
    final existing = _findDirectRoom(cachedRooms, peerId);
    final roomId = existing?.id ?? peerId;

    if (existing == null) {
      sl<ChatService>().prepareDirectConversation(
        userId: peerId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      if (context.mounted) {
        context.read<ChatBloc>().add(
              ChatDirectRoomPrepared(
                userId: peerId,
                displayName: displayName,
                avatarUrl: avatarUrl,
              ),
            );
      }
    }

    if (!context.mounted) return;
    await context.pushNamed(
      RoutesConstant.chatDetail,
      pathParameters: {'id': roomId},
      extra: ChatRoomType.direct,
    );
  }

  static ChatRoom? _findDirectRoom(List<ChatRoom> rooms, String userId) {
    for (final room in rooms) {
      if (!room.isDirect) continue;
      if (room.peerUserId == userId || room.id == userId) return room;
    }
    return null;
  }
}
