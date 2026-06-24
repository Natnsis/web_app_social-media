/// Group item from `GET /v1/groups`.
class GroupApiDto {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? lastMessage;
  final String? lastSenderName;
  final DateTime? updatedAt;
  final int unreadCount;
  final bool isMuted;
  final int memberCount;
  final bool isPrivate;

  const GroupApiDto({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.lastMessage,
    this.lastSenderName,
    this.updatedAt,
    this.unreadCount = 0,
    this.isMuted = false,
    this.memberCount = 0,
    this.isPrivate = false,
  });

  factory GroupApiDto.fromJson(Map<String, dynamic> json) {
    final count = json['_count'];
    final countMap = count is Map
        ? Map<String, dynamic>.from(count)
        : null;

    final image = json['imageUrl'] as String? ??
        json['image_url'] as String? ??
        json['image'] as String? ??
        json['coverImageUrl'] as String? ??
        json['cover_image_url'] as String? ??
        json['coverUrl'] as String? ??
        json['cover_url'] as String?;

    final updatedRaw = json['updatedAt'] ??
        json['updated_at'] ??
        json['lastMessageAt'] ??
        json['last_message_at'];

    return GroupApiDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: image,
      lastMessage: json['lastMessage'] as String? ??
          json['last_message'] as String? ??
          json['latestMessage'] as String?,
      lastSenderName: json['lastSenderName'] as String? ??
          json['last_sender_name'] as String?,
      updatedAt: DateTime.tryParse(updatedRaw?.toString() ?? ''),
      unreadCount: _int(json['unreadCount'] ?? json['unread_count']),
      isMuted: json['isMuted'] == true || json['is_muted'] == true,
      memberCount: _int(countMap?['members']),
      isPrivate: json['isPrivate'] == true || json['is_private'] == true,
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  /// Parses a single group from detail/create response bodies.
  static GroupApiDto? parseSingle(dynamic body) {
    final root = _asMap(body);
    if (root == null) return null;

    final data = _asMap(root['data']) ?? root;
    if (data.containsKey('id') || data.containsKey('name')) {
      return GroupApiDto.fromJson(data);
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
