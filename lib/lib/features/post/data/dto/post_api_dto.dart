import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/home/data/models/post_model.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/post/data/dto/post_nova_file_dto.dart';

/// Single post from `GET /v1/posts` (`data[]` item).
class PostApiDto {
  final String id;
  final String churchId;
  final String title;
  final String content;
  final String status;
  final List<String> novaFileIds;
  final bool isTagged;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? churchName;
  final String? churchLogoUrl;
  final String? churchSlug;
  final int likeCount;
  final int commentCount;
  final bool isLikedByMe;
  final bool isSavedByMe;
  final bool isOwnedByMe;
  final String? timeAgo;
  final List<PostNovaFileDto> files;

  const PostApiDto({
    required this.id,
    required this.churchId,
    required this.title,
    required this.content,
    this.status = '',
    this.novaFileIds = const [],
    this.isTagged = false,
    this.createdAt,
    this.updatedAt,
    this.churchName,
    this.churchLogoUrl,
    this.churchSlug,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByMe = false,
    this.isSavedByMe = false,
    this.isOwnedByMe = false,
    this.timeAgo,
    this.files = const [],
  });

  factory PostApiDto.fromJson(Map<String, dynamic> json) {
    final church = _asMap(json['church']);
    final count = _asMap(json['_count']);
    final files = _parseFiles(json['files']);

    return PostApiDto(
      id: json['id']?.toString() ?? '',
      churchId: json['churchId']?.toString() ?? church?['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? '',
      novaFileIds: _stringList(json['novaFileIds']),
      isTagged: json['isTagged'] == true,
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
      updatedAt: DateTime.tryParse(
        json['updatedAt']?.toString() ?? '',
      ),
      churchName: church?['name'] as String?,
      churchLogoUrl: church?['logoUrl'] as String?,
      churchSlug: church?['slug'] as String?,
      likeCount: _int(count?['likes']),
      commentCount: _int(count?['comments']),
      isLikedByMe: json['isLikedByMe'] == true ||
          json['isLiked'] == true ||
          json['isLikedByCurrentUser'] == true,
      isSavedByMe: json['isSavedByMe'] == true ||
          json['isSaved'] == true ||
          json['isSavedByCurrentUser'] == true,
      isOwnedByMe: json['isOwnedByMe'] == true || json['isOwnedByCurrentUser'] == true,
      timeAgo: json['timeAgo'] as String?,
      files: files,
    );
  }

  PostModel toPostModel({bool? forceSaved}) {
    final media = _resolveMedia(files);
    final body = _buildBody(title, content);

    return PostModel(
      id: id,
      authorName: churchName?.trim().isNotEmpty == true
          ? churchName!.trim()
          : 'Community',
      authorProfileId: churchId.isNotEmpty ? churchId : null,
      authorAvatarUrl: MediaUrlResolver.normalize(
        churchLogoUrl,
        imageOnly: true,
      ),
      content: body,
      imageUrl: media.imageUrl,
      mediaType: media.mediaType,
      tags: isTagged ? const ['Tagged'] : const [],
      likeCount: likeCount,
      commentCount: commentCount,
      isLiked: isLikedByMe,
      isOwnedByMe: isOwnedByMe,
      isSaved: forceSaved ?? isSavedByMe,
      timeAgoLabel: timeAgo,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static String _buildBody(String title, String content) {
    final t = title.trim();
    final c = content.trim();
    if (t.isEmpty) return c;
    if (c.isEmpty) return t;
    return '$t\n\n$c';
  }

  static _PostMedia _resolveMedia(List<PostNovaFileDto> files) {
    for (final file in files) {
      final url = MediaUrlResolver.normalize(file.novaUrl, imageOnly: false);
      if (url == null) continue;

      final type = file.mediaType.toLowerCase();
      final mime = file.mimeType.toLowerCase();

      if (type == 'video' || mime.startsWith('video/')) {
        return _PostMedia(imageUrl: url, mediaType: PostMediaType.video);
      }
      if (type == 'image' || mime.startsWith('image/')) {
        return _PostMedia(imageUrl: url, mediaType: PostMediaType.image);
      }
    }

    return const _PostMedia();
  }

  static List<PostNovaFileDto> _parseFiles(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((e) => _asMap(e))
        .whereType<Map<String, dynamic>>()
        .map(PostNovaFileDto.fromJson)
        .toList();
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

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
}

class _PostMedia {
  final String? imageUrl;
  final PostMediaType mediaType;

  const _PostMedia({
    this.imageUrl,
    this.mediaType = PostMediaType.text,
  });
}
