/// Pending join request from `GET /v1/groups/{id}/join-requests`.
class GroupJoinRequestApiDto {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final DateTime requestedAt;

  const GroupJoinRequestApiDto({
    required this.id,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.requestedAt,
  });

  factory GroupJoinRequestApiDto.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final userId = json['userId']?.toString() ??
        json['user_id']?.toString() ??
        user?['id']?.toString() ??
        '';
    final userName = json['userName'] as String? ??
        json['user_name'] as String? ??
        user?['fullName'] as String? ??
        user?['name'] as String? ??
        'Member';
    final avatar = json['avatarUrl'] as String? ??
        json['avatar_url'] as String? ??
        user?['avatarUrl'] as String? ??
        user?['avatar_url'] as String?;

    final createdRaw = json['createdAt'] ??
        json['created_at'] ??
        json['requestedAt'] ??
        json['requested_at'];

    return GroupJoinRequestApiDto(
      id: json['id']?.toString() ?? userId,
      userId: userId,
      userName: userName.trim().isNotEmpty ? userName.trim() : 'Member',
      avatarUrl: avatar,
      requestedAt: DateTime.tryParse(createdRaw?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
