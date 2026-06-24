import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';

sealed class GroupGovernanceState extends Equatable {
  const GroupGovernanceState();

  @override
  List<Object?> get props => [];
}

final class GroupGovernanceInitial extends GroupGovernanceState {
  const GroupGovernanceInitial();
}

final class GroupGovernanceLoading extends GroupGovernanceState {
  const GroupGovernanceLoading();
}

final class GroupGovernanceLoaded extends GroupGovernanceState {
  final ChatRoom room;
  final List<GroupMember> members;
  final List<GroupJoinRequest> pendingRequests;
  final List<GroupModeratorCandidate> inviteCandidates;
  final bool isRefreshing;
  final bool isActionInProgress;
  final bool joinRequestSent;
  final String? successMessage;
  final String? errorMessage;

  const GroupGovernanceLoaded({
    required this.room,
    this.members = const [],
    this.pendingRequests = const [],
    this.inviteCandidates = const [],
    this.isRefreshing = false,
    this.isActionInProgress = false,
    this.joinRequestSent = false,
    this.successMessage,
    this.errorMessage,
  });

  GroupGovernanceLoaded copyWith({
    ChatRoom? room,
    List<GroupMember>? members,
    List<GroupJoinRequest>? pendingRequests,
    List<GroupModeratorCandidate>? inviteCandidates,
    bool? isRefreshing,
    bool? isActionInProgress,
    bool? joinRequestSent,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return GroupGovernanceLoaded(
      room: room ?? this.room,
      members: members ?? this.members,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      inviteCandidates: inviteCandidates ?? this.inviteCandidates,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      joinRequestSent: joinRequestSent ?? this.joinRequestSent,
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        room,
        members,
        pendingRequests,
        inviteCandidates,
        isRefreshing,
        isActionInProgress,
        joinRequestSent,
        successMessage,
        errorMessage,
      ];
}

final class GroupGovernanceFailure extends GroupGovernanceState {
  final String message;

  const GroupGovernanceFailure(this.message);

  @override
  List<Object?> get props => [message];
}
