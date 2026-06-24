import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_event.dart';
import 'package:faithconnect/features/home/presentation/widgets/home_sidebar_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Entry points for the community groups inbox (chat list → Groups tab).
abstract final class GroupsNavigation {
  GroupsNavigation._();

  static void openGroups(BuildContext context) {
    context.read<ChatBloc>().add(
          const ChatListRestoreRequested(inboxTab: ChatRoomType.group),
        );

    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      shell.goBranch(
        HomeSidebarMenu.groupsBranchIndex,
        initialLocation:
            shell.currentIndex == HomeSidebarMenu.groupsBranchIndex,
      );
      return;
    }

    context.go('${RoutesConstant.chatList}?tab=groups');
  }
}
