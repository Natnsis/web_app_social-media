import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_event.dart';
import 'package:faithconnect/features/chat/presentation/widgets/group_info_sheet.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class GroupGovernanceNavigation {
  GroupGovernanceNavigation._();

  /// Group management page — join requests, approve/reject, invite member.
  static Future<void> showGroupInfoSheet(
    BuildContext context, {
    required ChatRoom room,
    bool showJoinRequestAction = false,
    bool showAdminActions = true,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) {
          return BlocProvider(
            create: (_) => sl<GroupGovernanceBloc>(param1: room.id)
              ..add(GroupGovernanceRequested(room)),
            child: GroupInfoSheet(
              room: room,
              showJoinRequestAction: showJoinRequestAction,
              showAdminActions: showAdminActions,
            ),
          );
        },
      ),
    );
  }
}
