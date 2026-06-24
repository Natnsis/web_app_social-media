/// Group member from `GET /v1/groups/{id}/members`.
class GroupMemberApiDto {
  final String id;
  final String userId;
  final String? name;
  final String? avatarUrl;
  final String? role;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final String? lastSeenText;
  final DateTime? joinedAt;

  const GroupMemberApiDto({
    required this.id,
    required this.userId,
    this.name,
    this.avatarUrl,
    this.role,
    this.isOnline = false,
    this.lastSeenAt,
    this.lastSeenText,
    this.joinedAt,
  });

  factory GroupMemberApiDto.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    return GroupMemberApiDto(
      id: json['id']?.toString() ?? user?['id']?.toString() ?? '',
      userId: json['userId']?.toString() ??
          user?['id']?.toString() ??
          json['memberId']?.toString() ??
          json['id']?.toString() ??
          '',
      name: json['fullName'] as String? ??
          user?['fullName'] as String? ??
          user?['name'] as String? ??
          json['name'] as String? ??
          json['userName'] as String?,
      avatarUrl: json['avatarUrl'] as String? ??
          user?['avatarUrl'] as String? ??
          user?['logoUrl'] as String?,
      role: json['role'] as String? ?? json['permission'] as String?,
      isOnline: json['isOnline'] == true ||
          json['isOnline']?.toString() == 'true' ||
          user?['isOnline'] == true ||
          user?['isOnline']?.toString() == 'true',
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'].toString())?.toLocal()
          : (user?['lastSeenAt'] != null
              ? DateTime.tryParse(user!['lastSeenAt'].toString())?.toLocal()
              : null),
      lastSeenText: json['lastSeenText'] as String? ?? user?['lastSeenText'] as String?,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())?.toLocal()
          : null,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
