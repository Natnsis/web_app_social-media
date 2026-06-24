/// Church moderator from `GET /v1/churches/{id}` and `GET/POST /v1/churches/{id}/members`.
class ChurchMemberApiDto {
  final String id;
  final String userId;
  final String? churchId;
  final String? assignedByUserId;
  final DateTime? assignedAt;
  final String? assignedById;
  final String? assignedByName;
  final String? name;
  final String? avatarUrl;
  final bool? isOnline;
  final String? role;

  const ChurchMemberApiDto({
    required this.id,
    required this.userId,
    this.churchId,
    this.assignedByUserId,
    this.assignedAt,
    this.assignedById,
    this.assignedByName,
    this.name,
    this.avatarUrl,
    this.isOnline,
    this.role,
  });

  factory ChurchMemberApiDto.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final assignedBy = _asMap(json['assignedBy']);
    final assignedAt = json['assignedAt'] as String?;

    return ChurchMemberApiDto(
      id: json['id']?.toString() ?? user?['id']?.toString() ?? '',
      userId: json['userId']?.toString() ??
          user?['id']?.toString() ??
          json['memberId']?.toString() ??
          '',
      churchId: json['churchId']?.toString(),
      assignedByUserId: json['assignedByUserId']?.toString() ??
          assignedBy?['id']?.toString(),
      assignedAt: assignedAt == null ? null : DateTime.tryParse(assignedAt),
      assignedById: assignedBy?['id']?.toString() ??
          json['assignedByUserId']?.toString(),
      assignedByName: assignedBy?['fullName'] as String? ??
          assignedBy?['name'] as String?,
      name: user?['fullName'] as String? ??
          user?['name'] as String? ??
          json['name'] as String? ??
          json['userName'] as String?,
      avatarUrl: user?['avatarUrl'] as String? ??
          user?['logoUrl'] as String? ??
          json['avatarUrl'] as String?,
      isOnline: _parseBool(user?['isOnline']) ?? _parseBool(json['isOnline']),
      role: json['role'] as String? ?? json['permission'] as String?,
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  static ChurchMemberApiDto parseResponse(dynamic body) {
    final root = _asMap(body) ?? {};
    final data = _asMap(root['data']) ?? root;
    return ChurchMemberApiDto.fromJson(data);
  }

  static List<ChurchMemberApiDto> parseListResponse(dynamic body) {
    final root = _asMap(body) ?? {};
    final rawList = root['data'];
    if (rawList is! List) return const [];

    return rawList
        .map((entry) {
          final map = _asMap(entry);
          if (map == null) return null;
          return ChurchMemberApiDto.fromJson(map);
        })
        .whereType<ChurchMemberApiDto>()
        .where((item) => item.userId.isNotEmpty)
        .toList();
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
