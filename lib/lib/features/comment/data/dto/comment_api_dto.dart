/// Single comment or reply from comment APIs (`data` item).
class CommentApiDto {
  final String id;
  final String body;
  final String? authorName;
  final String? authorAvatarUrl;
  final int likeCount;
  final DateTime? createdAt;
  final String? parentId;
  final String? authorId;
  final bool isLikedByMe;
  final bool isOwnedByMe;
  final int replyCount;
  final List<Map<String, dynamic>> reads;

  const CommentApiDto({
    required this.id,
    required this.body,
    this.authorName,
    this.authorAvatarUrl,
    this.likeCount = 0,
    this.createdAt,
    this.parentId,
    this.authorId,
    this.isLikedByMe = false,
    this.isOwnedByMe = false,
    this.replyCount = 0,
    this.reads = const [],
  });

  factory CommentApiDto.fromJson(Map<String, dynamic> json) {
    final author = _asMap(json['author']) ?? _asMap(json['user']);
    final church = _asMap(json['church']);

    return CommentApiDto(
      id: json['id']?.toString() ?? '',
      body: json['body'] as String? ??
          json['content'] as String? ??
          json['text'] as String? ??
          '',
      authorName: author?['fullName'] as String? ??
          author?['name'] as String? ??
          church?['name'] as String? ??
          json['authorName'] as String?,
      authorAvatarUrl: author?['avatarUrl'] as String? ??
          author?['logoUrl'] as String? ??
          church?['logoUrl'] as String? ??
          json['authorAvatarUrl'] as String?,
      likeCount: _int(json['likeCount'] ?? _asMap(json['_count'])?['likes']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      parentId: json['parentId']?.toString() ?? json['parentCommentId']?.toString(),
      authorId: author?['id']?.toString() ??
          church?['id']?.toString() ??
          json['authorId']?.toString() ??
          json['userId']?.toString(),
      isLikedByMe: json['isLikedByMe'] == true || json['isLiked'] == true,
      isOwnedByMe: json['isOwnedByMe'] == true ||
          json['is_owned_by_me'] == true ||
          json['isAuthor'] == true ||
          json['isMine'] == true ||
          json['canDelete'] == true ||
          json['canEdit'] == true,
      replyCount: _replyCount(json),
      reads: (json['reads'] as List?)
              ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
              .toList() ??
          const [],
    );
  }

  /// Resolves ownership when the API omits explicit flags but includes author id.
  bool ownedBy({String? userId, String? churchId}) {
    if (isOwnedByMe) return true;

    final author = authorId?.trim();
    if (author == null || author.isEmpty) return false;

    final me = userId?.trim();
    if (me != null && me.isNotEmpty && author == me) return true;

    final church = churchId?.trim();
    if (church != null && church.isNotEmpty && author == church) return true;

    return false;
  }

  /// Flattens a comment list that may embed nested `replies` arrays.
  static List<CommentApiDto> flattenList(dynamic body) {
    final rawList = _extractRawList(body);
    final byId = <String, CommentApiDto>{};

    for (final entry in rawList) {
      final map = _asMap(entry);
      if (map == null) continue;
      for (final dto in _flattenMap(map)) {
        if (dto.id.isEmpty) continue;
        byId[dto.id] = dto;
      }
    }

    return byId.values.toList();
  }

  static List<CommentApiDto> _flattenMap(Map<String, dynamic> json) {
    final items = <CommentApiDto>[CommentApiDto.fromJson(json)];
    final replies = json['replies'];
    if (replies is List) {
      for (final reply in replies) {
        final replyMap = _asMap(reply);
        if (replyMap != null) {
          items.addAll(_flattenMap(replyMap));
        }
      }
    }
    return items;
  }

  static List<dynamic> _extractRawList(dynamic body) {
    if (body is List) return body;

    final root = _asMap(body);
    if (root == null) return const [];

    final data = root['data'];
    if (data is List) return data;

    final nested = _asMap(data);
    if (nested != null) {
      final inner = nested['data'];
      if (inner is List) return inner;
      final items = nested['items'];
      if (items is List) return items;
    }

    final items = root['items'];
    if (items is List) return items;

    return const [];
  }

  static int _replyCount(Map<String, dynamic> json) {
    final explicit = json['replyCount'] ?? _asMap(json['_count'])?['replies'];
    if (explicit != null) return _int(explicit);

    final replies = json['replies'];
    if (replies is List && replies.isNotEmpty) return replies.length;

    return 0;
  }

  static CommentApiDto parseResponse(dynamic body) {
    final root = _asMap(body) ?? {};
    final dataField = root['data'];
    final data = dataField != null ? _unwrapEntity(dataField) : root;
    return CommentApiDto.fromJson(data);
  }

  /// Unwraps `{ data: comment }` and `{ data: { data: comment } }` envelopes.
  static Map<String, dynamic> _unwrapEntity(dynamic value) {
    var map = _asMap(value);
    if (map == null) return {};

    final nested = _asMap(map['data']);
    if (nested != null &&
        nested['id'] != null &&
        (map['id'] == null || map['id'].toString().isEmpty)) {
      return nested;
    }

    return map;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
