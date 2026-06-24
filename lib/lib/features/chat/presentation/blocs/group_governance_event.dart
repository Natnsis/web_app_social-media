import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/core/services/socket/messaging_socket_payloads.dart';

sealed class GroupGovernanceEvent extends Equatable {
  const GroupGovernanceEvent();

  @override
  List<Object?> get props => [];
}

final class GroupGovernanceRequested extends GroupGovernanceEvent {
  final ChatRoom room;

  const GroupGovernanceRequested(this.room);

  @override
  List<Object?> get props => [room];
}

final class GroupGovernanceRefreshed extends GroupGovernanceEvent {
  const GroupGovernanceRefreshed();
}

final class GroupJoinRequested extends GroupGovernanceEvent {
  const GroupJoinRequested();
}

final class GroupJoinRequestApproved extends GroupGovernanceEvent {
  final String userId;

  const GroupJoinRequestApproved(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class GroupJoinRequestRejected extends GroupGovernanceEvent {
  final String userId;

  const GroupJoinRequestRejected(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class GroupMemberInvited extends GroupGovernanceEvent {
  final String userId;

  const GroupMemberInvited(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class GroupMemberRemoved extends GroupGovernanceEvent {
  final String userId;

  const GroupMemberRemoved(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class GroupMemberBanned extends GroupGovernanceEvent {
  final String userId;

  const GroupMemberBanned(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class GroupLeft extends GroupGovernanceEvent {
  const GroupLeft();
}

final class GroupGovernanceMessageCleared extends GroupGovernanceEvent {
  const GroupGovernanceMessageCleared();
}

/// Socket event — `presence:online` / `presence:offline`.
final class GroupGovernancePresenceStatusChanged extends GroupGovernanceEvent {
  final PresencePayload payload;

  const GroupGovernancePresenceStatusChanged(this.payload);

  @override
  List<Object?> get props => [payload];
}
