import 'package:equatable/equatable.dart';

/// Like state returned after `POST` / `DELETE /v1/posts/{id}/like`.
class PostLikeState extends Equatable {
  final int likeCount;
  final bool isLiked;

  const PostLikeState({
    required this.likeCount,
    required this.isLiked,
  });

  @override
  List<Object?> get props => [likeCount, isLiked];
}
