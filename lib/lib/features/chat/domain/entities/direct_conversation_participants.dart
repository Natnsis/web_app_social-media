import 'package:equatable/equatable.dart';

/// Participant pair from `conversation.participantA` / `participantB` on messaging API.
class DirectConversationParticipants extends Equatable {
  final String participantAId;
  final String participantAName;
  final String? participantAAvatarUrl;
  final String participantBId;
  final String participantBName;
  final String? participantBAvatarUrl;

  const DirectConversationParticipants({
    required this.participantAId,
    required this.participantAName,
    this.participantAAvatarUrl,
    required this.participantBId,
    required this.participantBName,
    this.participantBAvatarUrl,
  });

  factory DirectConversationParticipants.fromApi({
    required String participantAId,
    required String participantAName,
    String? participantAAvatarUrl,
    required String participantBId,
    required String participantBName,
    String? participantBAvatarUrl,
  }) {
    return DirectConversationParticipants(
      participantAId: participantAId,
      participantAName: participantAName,
      participantAAvatarUrl: participantAAvatarUrl,
      participantBId: participantBId,
      participantBName: participantBName,
      participantBAvatarUrl: participantBAvatarUrl,
    );
  }

  /// Other participant for the logged-in user; falls back to participantB.
  ({
    String id,
    String name,
    String? avatarUrl,
  }) peerForUser(String? currentUserId) {
    final me = currentUserId?.trim();
    if (me != null && me.isNotEmpty) {
      if (me == participantAId && participantBId.isNotEmpty) {
        return (
          id: participantBId,
          name: _name(participantBName),
          avatarUrl: participantBAvatarUrl,
        );
      }
      if (me == participantBId && participantAId.isNotEmpty) {
        return (
          id: participantAId,
          name: _name(participantAName),
          avatarUrl: participantAAvatarUrl,
        );
      }
    }
    return (
      id: participantBId.isNotEmpty ? participantBId : participantAId,
      name: _name(
        participantBName.isNotEmpty ? participantBName : participantAName,
      ),
      avatarUrl: participantBAvatarUrl ?? participantAAvatarUrl,
    );
  }

  bool isCurrentUser(String? userId, String participantId) {
    final me = userId?.trim();
    return me != null && me.isNotEmpty && me == participantId;
  }

  bool isMessageMine(String senderId, String? currentUserId) {
    final me = currentUserId?.trim();
    if (me != null && me.isNotEmpty) return senderId == me;
    return false;
  }

  String? participantName(String participantId) {
    if (participantId == participantAId) return _name(participantAName);
    if (participantId == participantBId) return _name(participantBName);
    return null;
  }

  String? participantAvatar(String participantId) {
    if (participantId == participantAId) return participantAAvatarUrl;
    if (participantId == participantBId) return participantBAvatarUrl;
    return null;
  }

  static String _name(String value) =>
      value.trim().isNotEmpty ? value.trim() : 'Member';

  @override
  List<Object?> get props => [
        participantAId,
        participantAName,
        participantAAvatarUrl,
        participantBId,
        participantBName,
        participantBAvatarUrl,
      ];
}
