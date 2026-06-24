import 'package:faithconnect/features/comment/domain/entities/comment_like_state.dart';

/// Parses like/unlike responses for `/v1/comments/{id}/like`.
class CommentLikeResultDto {
  final int likeCount;
  final bool isLiked;

  const CommentLikeResultDto({
    required this.likeCount,
    required this.isLiked,
  });

  factory CommentLikeResultDto.fromJson(Map<String, dynamic> json) {
    final count = _asMap(json['_count']);
    return CommentLikeResultDto(
      likeCount: _int(json['likeCount'] ?? count?['likes']),
      isLiked: json['isLikedByMe'] == true || json['liked'] == true,
    );
  }

  static CommentLikeResultDto parseResponse(dynamic body, {required bool liked}) {
    final root = _asMap(body) ?? {};
    final data = _asMap(root['data']);
    if (data != null) {
      return CommentLikeResultDto.fromJson(data);
    }
    return CommentLikeResultDto(
      likeCount: _int(root['likeCount']),
      isLiked: root['isLikedByMe'] == true || root['liked'] == true || liked,
    );
  }

  CommentLikeState toEntity() =>
      CommentLikeState(likeCount: likeCount, isLiked: isLiked);

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
