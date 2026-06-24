import 'package:faithconnect/features/post/domain/entities/post_like_state.dart';

/// Parses like/unlike responses for `/v1/posts/{id}/like`.
class PostLikeResultDto {
  /// -1 means the server didn't return a count (e.g. 204 No Content).
  final int likeCount;
  final bool isLiked;

  const PostLikeResultDto({
    required this.likeCount,
    required this.isLiked,
  });

  factory PostLikeResultDto.fromJson(
    Map<String, dynamic> json, {
    bool? fallbackLiked,
  }) {
    final countMap = _asMap(json['_count']);
    final rawCount = json['likeCount'] ?? countMap?['likes'] ?? countMap?['likesCount'];
    return PostLikeResultDto(
      likeCount: rawCount != null ? _int(rawCount) : -1,
      isLiked: json['isLikedByMe'] == true ||
          json['isLiked'] == true ||
          json['isLikedByCurrentUser'] == true ||
          (fallbackLiked ?? false),
    );
  }

  static PostLikeResultDto parseResponse(dynamic body, {required bool liked}) {
    final root = _asMap(body) ?? {};

    // Unwrap { data: { ... } } envelope
    final data = _asMap(root['data']);
    if (data != null && data.isNotEmpty) {
      return PostLikeResultDto.fromJson(data, fallbackLiked: liked);
    }

    // Bare response or empty body (e.g. 204 No Content)
    if (root.isEmpty) {
      return PostLikeResultDto(likeCount: -1, isLiked: liked);
    }

    final rawCount = root['likeCount'] ?? _asMap(root['_count'])?['likes'];
    return PostLikeResultDto(
      likeCount: rawCount != null ? _int(rawCount) : -1,
      isLiked: root['isLikedByMe'] == true ||
          root['isLiked'] == true ||
          root['liked'] == true ||
          liked,
    );
  }

  /// Converts to a domain entity. If the server omitted the count (-1),
  /// the caller should keep its own optimistic count.
  PostLikeState toEntity() =>
      PostLikeState(likeCount: likeCount, isLiked: isLiked);

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
