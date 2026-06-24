import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/domain/entities/direct_conversation_participants.dart';

class ChatRoom extends Equatable {
  final String id;
  final String title;
  final ChatRoomType type;
  final String? avatarUrl;
  final String? lastMessage;
  final String? lastSenderName;
  final String timestampLabel;
  final DateTime? updatedAt;
  final int unreadCount;
  final bool isMuted;
  final bool isOnline;
  final bool hasUnreadDot;
  final String? initials;
  final String? statusSubtitle;

  /// Other participant's user id — used for first direct message via socket.
  final String? peerUserId;

  /// From API `conversation.participantA` / `participantB` on direct threads.
  final DirectConversationParticipants? directParticipants;

  /// Group-only flags from `GET /v1/groups`.
  final bool isPrivate;
  final int memberCount;

  const ChatRoom({
    required this.id,
    required this.title,
    required this.type,
    this.avatarUrl,
    this.lastMessage,
    this.lastSenderName,
    this.timestampLabel = '',
    this.updatedAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isOnline = false,
    this.hasUnreadDot = false,
    this.initials,
    this.statusSubtitle,
    this.peerUserId,
    this.directParticipants,
    this.isPrivate = false,
    this.memberCount = 0,
  });

  bool get isDirect => type == ChatRoomType.direct;

  bool get isGroup => type == ChatRoomType.group;

  ChatRoom copyWith({
    String? id,
    String? title,
    ChatRoomType? type,
    String? avatarUrl,
    String? lastMessage,
    String? lastSenderName,
    String? timestampLabel,
    DateTime? updatedAt,
    int? unreadCount,
    bool? isMuted,
    bool? isOnline,
    bool? hasUnreadDot,
    String? initials,
    String? statusSubtitle,
    String? peerUserId,
    DirectConversationParticipants? directParticipants,
    bool? isPrivate,
    int? memberCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastSenderName: lastSenderName ?? this.lastSenderName,
      timestampLabel: timestampLabel ?? this.timestampLabel,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      isOnline: isOnline ?? this.isOnline,
      hasUnreadDot: hasUnreadDot ?? this.hasUnreadDot,
      initials: initials ?? this.initials,
      statusSubtitle: statusSubtitle ?? this.statusSubtitle,
      peerUserId: peerUserId ?? this.peerUserId,
      directParticipants: directParticipants ?? this.directParticipants,
      isPrivate: isPrivate ?? this.isPrivate,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  /// Display name for direct inbox / app bar using participantA/B.
  String displayTitleForUser(String? currentUserId) {
    if (!isDirect) return title;
    final peer = directParticipants?.peerForUser(currentUserId);
    if (peer != null && peer.name.isNotEmpty) return peer.name;
    return title;
  }

  String get previewText {
    final body = lastMessage?.trim();
    if (body == null || body.isEmpty) return 'Start a conversation';
    if (isDirect) {
      if (lastSenderName == 'You') return 'You: $body';
      return body;
    }
    if (lastSenderName != null && lastSenderName!.isNotEmpty) {
      return '$lastSenderName: $body';
    }
    return body;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        avatarUrl,
        lastMessage,
        lastSenderName,
        timestampLabel,
        updatedAt,
        unreadCount,
        isMuted,
        isOnline,
        hasUnreadDot,
        initials,
        statusSubtitle,
        peerUserId,
        directParticipants,
        isPrivate,
        memberCount,
      ];
}
