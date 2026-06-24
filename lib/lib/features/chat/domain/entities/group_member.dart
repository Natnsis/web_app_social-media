import 'package:equatable/equatable.dart';

class GroupMember extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? role;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final String? lastSeenText;
  final DateTime? joinedAt;

  const GroupMember({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.role,
    this.isOnline = false,
    this.lastSeenAt,
    this.lastSeenText,
    this.joinedAt,
  });

  GroupMember copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatarUrl,
    String? role,
    bool? isOnline,
    DateTime? lastSeenAt,
    String? lastSeenText,
    DateTime? joinedAt,
    bool clearLastSeenText = false,
  }) {
    return GroupMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastSeenText: clearLastSeenText ? null : (lastSeenText ?? this.lastSeenText),
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, name, avatarUrl, role, isOnline, lastSeenAt, lastSeenText, joinedAt];
}
