/// Church summary nested in `GET /v1/shorts` list items.
class ShortChurchApiDto {
  final String id;
  final String name;
  final String? logoUrl;
  final String? slug;

  const ShortChurchApiDto({
    required this.id,
    required this.name,
    this.logoUrl,
    this.slug,
  });

  factory ShortChurchApiDto.fromJson(Map<String, dynamic> json) {
    return ShortChurchApiDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      slug: json['slug'] as String?,
    );
  }
}

/// Nova file metadata nested in short list items.
class ShortNovaFileApiDto {
  final String? novaVideoId;
  final String? streamCode;
  final String? appId;
  final bool isReady;
  final String? novaUrl;
  final String? mediaType;

  const ShortNovaFileApiDto({
    this.novaVideoId,
    this.streamCode,
    this.appId,
    this.isReady = false,
    this.novaUrl,
    this.mediaType,
  });

  factory ShortNovaFileApiDto.fromJson(Map<String, dynamic> json) {
    return ShortNovaFileApiDto(
      novaVideoId: json['novaVideoId']?.toString(),
      streamCode: json['streamCode'] as String?,
      appId: json['appId']?.toString(),
      isReady: json['isReady'] == true,
      novaUrl: json['novaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
    );
  }
}

/// Single short from `GET /v1/shorts` (`data[]` item).
class ShortApiDto {
  final String id;
  final String churchId;
  final String title;
  final String description;
  final String? videoUrl;
  final String? novaFileId;
  final bool isPublished;
  final DateTime? publishedAt;
  final int viewCount;
  final DateTime? createdAt;
  final String? timeAgo;
  final ShortChurchApiDto? church;
  final ShortNovaFileApiDto? novaFile;
  final int likeCount;
  final int commentCount;
  final bool isLikedByMe;

  const ShortApiDto({
    required this.id,
    required this.churchId,
    required this.title,
    required this.description,
    this.videoUrl,
    this.novaFileId,
    this.isPublished = false,
    this.publishedAt,
    this.viewCount = 0,
    this.createdAt,
    this.timeAgo,
    this.church,
    this.novaFile,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByMe = false,
  });

  factory ShortApiDto.fromJson(Map<String, dynamic> json) {
    final churchMap = _asMap(json['church']);
    final novaFileMap = _asMap(json['novaFile']);
    final count = _asMap(json['_count']);

    return ShortApiDto(
      id: json['id']?.toString() ?? '',
      churchId: json['churchId']?.toString() ?? churchMap?['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
      novaFileId: json['novaFileId']?.toString(),
      isPublished: json['isPublished'] == true,
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
      viewCount: _int(json['viewCount']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      timeAgo: json['timeAgo'] as String?,
      church: churchMap == null ? null : ShortChurchApiDto.fromJson(churchMap),
      novaFile:
          novaFileMap == null ? null : ShortNovaFileApiDto.fromJson(novaFileMap),
      likeCount: _int(count?['likes']),
      commentCount: _int(count?['comments']),
      isLikedByMe: json['isLikedByMe'] == true,
    );
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
