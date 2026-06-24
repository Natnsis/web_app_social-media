import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/services/socket/group_chat_socket_service.dart';
import 'package:faithconnect/features/chat/application/chat_service.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:faithconnect/core/utils/group_access_errors.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_event.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupGovernanceBloc
    extends Bloc<GroupGovernanceEvent, GroupGovernanceState> {
  final ChatService _chatService;
  final GroupChatSocketService _groupChatSocket;
  final String groupId;

  StreamSubscription? _presenceOnlineSub;
  StreamSubscription? _presenceOfflineSub;

  GroupGovernanceBloc({
    required ChatService chatService,
    required GroupChatSocketService groupChatSocket,
    required this.groupId,
  })  : _chatService = chatService,
        _groupChatSocket = groupChatSocket,
        super(const GroupGovernanceInitial()) {
    on<GroupGovernanceRequested>(_onRequested);
    on<GroupGovernanceRefreshed>(_onRefreshed);
    on<GroupJoinRequested>(_onJoinRequested);
    on<GroupJoinRequestApproved>(_onApproved);
    on<GroupJoinRequestRejected>(_onRejected);
    on<GroupMemberInvited>(_onMemberInvited);
    on<GroupMemberRemoved>(_onMemberRemoved);
    on<GroupMemberBanned>(_onMemberBanned);
    on<GroupLeft>(_onGroupLeft);
    on<GroupGovernanceMessageCleared>(_onMessageCleared);
    on<GroupGovernancePresenceStatusChanged>(_onPresenceStatusChanged);

    _presenceOnlineSub = _groupChatSocket.onPresenceOnline.listen(
      (payload) => add(GroupGovernancePresenceStatusChanged(payload)),
    );
    _presenceOfflineSub = _groupChatSocket.onPresenceOffline.listen(
      (payload) => add(GroupGovernancePresenceStatusChanged(payload)),
    );
  }

  @override
  Future<void> close() {
    _presenceOnlineSub?.cancel();
    _presenceOfflineSub?.cancel();
    return super.close();
  }

  Future<void> _onRequested(
    GroupGovernanceRequested event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    emit(const GroupGovernanceLoading());
    await _load(emit, room: event.room, showLoading: true);
  }

  Future<void> _onRefreshed(
    GroupGovernanceRefreshed event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    final current = state;
    if (current is! GroupGovernanceLoaded) return;
    emit(current.copyWith(isRefreshing: true, clearMessages: true));
    await _load(emit, room: current.room, showLoading: false);
  }

  Future<void> _load(
    Emitter<GroupGovernanceState> emit, {
    required ChatRoom room,
    required bool showLoading,
  }) async {
    final membersResult = await _chatService.fetchGroupMembers(groupId);
    final requestsResult = await _chatService.fetchGroupJoinRequests(groupId);
    final candidatesResult = await _chatService.getModeratorCandidates();

    final members = membersResult.fold(
      (_) => const <GroupMember>[],
      (value) => value,
    );
    final requests = requestsResult.fold(
      (_) => const <GroupJoinRequest>[],
      (value) => value,
    );
    final candidates = candidatesResult.fold(
      (_) => const <GroupModeratorCandidate>[],
      (value) => value,
    );

    final membersError =
        membersResult.fold((failure) => failure.message, (_) => null);
    final requestsError =
        requestsResult.fold((failure) => failure.message, (_) => null);
    final candidatesError =
        candidatesResult.fold((failure) => failure.message, (_) => null);
    final errorMessage = GroupAccessErrors.firstSignificantError([
      membersError,
      requestsError,
      candidatesError,
    ]);

    if (showLoading &&
        members.isEmpty &&
        requests.isEmpty &&
        candidates.isEmpty &&
        errorMessage != null) {
      emit(GroupGovernanceFailure(errorMessage));
      return;
    }

    final currentUserId = (await SharedPrefsService.getUserId())?.trim();
    final hasOwnPendingRequest = currentUserId != null &&
        currentUserId.isNotEmpty &&
        requests.any((request) => request.userId == currentUserId);

    final memberCount =
        members.isNotEmpty ? members.length : room.memberCount;

    emit(
      GroupGovernanceLoaded(
        room: room.copyWith(memberCount: memberCount),
        members: members,
        pendingRequests: requests,
        inviteCandidates: candidates,
        joinRequestSent: hasOwnPendingRequest,
        errorMessage: errorMessage,
      ),
    );
  }

  Future<void> _onJoinRequested(
    GroupJoinRequested event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    final current = state;
    if (current is! GroupGovernanceLoaded) return;

    emit(current.copyWith(isActionInProgress: true, clearMessages: true));
    final result = await _chatService.requestGroupJoin(groupId);
    await result.fold(
      (failure) async {
        emit(
          current.copyWith(
            isActionInProgress: false,
            errorMessage: GroupAccessErrors.userFacingOrNull(failure.message),
          ),
        );
      },
      (_) async {
        final refreshed = await _chatService.fetchGroupJoinRequests(groupId);
        final requests = refreshed.fold(
          (_) => current.pendingRequests,
          (value) => value,
        );
        emit(
          current.copyWith(
            pendingRequests: requests,
            isActionInProgress: false,
            joinRequestSent: true,
            successMessage: 'Join request sent. An admin will review it soon.',
          ),
        );
      },
    );
  }

  Future<void> _onApproved(
    GroupJoinRequestApproved event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    await _mutateRequest(
      emit,
      action: () => _chatService.approveGroupJoinRequest(
        groupId: groupId,
        userId: event.userId,
      ),
      successMessage: 'Join request approved.',
      removeUserId: event.userId,
    );
  }

  Future<void> _onRejected(
    GroupJoinRequestRejected event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    await _mutateRequest(
      emit,
      action: () => _chatService.rejectGroupJoinRequest(
        groupId: groupId,
        userId: event.userId,
      ),
      successMessage: 'Join request rejected.',
      removeUserId: event.userId,
    );
  }

  Future<void> _onMemberInvited(
    GroupMemberInvited event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    final current = state;
    if (current is! GroupGovernanceLoaded) return;

    emit(current.copyWith(isActionInProgress: true, clearMessages: true));
    final result = await _chatService.inviteGroupMember(
      groupId: groupId,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(
        current.copyWith(
          isActionInProgress: false,
          errorMessage: GroupAccessErrors.userFacingOrNull(failure.message),
        ),
      ),
      (_) => emit(
        current.copyWith(
          isActionInProgress: false,
          successMessage: 'Invitation sent.',
        ),
      ),
    );
  }

  Future<void> _onMemberRemoved(
    GroupMemberRemoved event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    final current = state;
    if (current is! GroupGovernanceLoaded) return;

    emit(current.copyWith(isActionInProgress: true, clearMessages: true));
    final result = await _chatService.removeGroupMember(
      groupId: groupId,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(
        current.copyWith(
          isActionInProgress: false,
          errorMessage: GroupAccessErrors.userFacingOrNull(failure.message),
        ),
      ),
      (_) {
        final updatedMembers = current.members
            .where((m) => m.userId != event.userId)
            .toList(growable: false);
        emit(
          current.copyWith(
            members: updatedMembers,
            room: current.room.copyWith(memberCount: updatedMembers.length),
            isActionInProgress: false,
            successMessage: 'Member removed.',
          ),
        );
      },
    );
  }

  Future<void> _onMemberBanned(
    GroupMemberBanned event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    final current = state;
    if (current is! GroupGovernanceLoaded) return;

    emit(current.copyWith(isActionInProgress: true, clearMessages: true));
    final result = await _chatService.banGroupMember(
      groupId: groupId,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(
        current.copyWith(
          isActionInProgress: false,
          errorMessage: GroupAccessErrors.userFacingOrNull(failure.message),
        ),
      ),
      (_) {
        final updatedMembers = current.members
            .where((m) => m.userId != event.userId)
            .toList(growable: false);
        emit(
          current.copyWith(
            members: updatedMembers,
            room: current.room.copyWith(memberCount: updatedMembers.length),
            isActionInProgress: false,
            successMessage: 'Member banned.',
          ),
        );
      },
    );
  }

  Future<void> _onGroupLeft(
    GroupLeft event,
    Emitter<GroupGovernanceState> emit,
  ) async {
    final current = state;
    if (current is! GroupGovernanceLoaded) return;

    emit(current.copyWith(isActionInProgress: true, clearMessages: true));
    final result = await _chatService.leaveGroup(groupId);
    result.fold(
      (failure) => emit(
        current.copyWith(
          isActionInProgress: false,
          errorMessage: GroupAccessErrors.userFacingOrNull(failure.message),
        ),
      ),
      (_) {
        // Since user left, they can no longer govern or see it
        emit(
          current.copyWith(
            isActionInProgress: false,
            successMessage: 'You left the group.',
            // Optionally clear members or change state
          ),
        );
      },
    );
  }

  Future<void> _mutateRequest(
    Emitter<GroupGovernanceState> emit, {
    required Future<Either<Failure, void>> Function() action,
    required String successMessage,
    required String removeUserId,
  }) async {
    final current = state;
    if (current is! GroupGovernanceLoaded) return;

    emit(current.copyWith(isActionInProgress: true, clearMessages: true));
    final result = await action();
    await result.fold(
      (failure) async {
        emit(
          current.copyWith(
            isActionInProgress: false,
            errorMessage: GroupAccessErrors.userFacingOrNull(failure.message),
          ),
        );
      },
      (_) async {
        final updated = current.pendingRequests
            .where((request) => request.userId != removeUserId)
            .toList(growable: false);
        final membersResult = await _chatService.fetchGroupMembers(groupId);
        final members = membersResult.fold(
          (_) => current.members,
          (value) => value,
        );
        emit(
          current.copyWith(
            room: members.isNotEmpty
                ? current.room.copyWith(memberCount: members.length)
                : current.room,
            members: members,
            pendingRequests: updated,
            isActionInProgress: false,
            successMessage: successMessage,
          ),
        );
      },
    );
  }

  void _onMessageCleared(
    GroupGovernanceMessageCleared event,
    Emitter<GroupGovernanceState> emit,
  ) {
    final current = state;
    if (current is GroupGovernanceLoaded) {
      emit(current.copyWith(clearMessages: true));
    }
  }

  void _onPresenceStatusChanged(
    GroupGovernancePresenceStatusChanged event,
    Emitter<GroupGovernanceState> emit,
  ) {
    final current = state;
    if (current is GroupGovernanceLoaded) {
      final updatedMembers = current.members.map((m) {
        if (m.userId == event.payload.userId) {
          return m.copyWith(
            isOnline: event.payload.isOnline,
            lastSeenAt: event.payload.lastSeenAt,
            lastSeenText: event.payload.isOnline ? 'online' : 'offline',
          );
        }
        return m;
      }).toList();

      emit(current.copyWith(members: updatedMembers));
    }
  }
}
