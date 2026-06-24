import 'package:equatable/equatable.dart';

/// Like state returned after `POST` / `DELETE /v1/comments/{id}/like`.
class CommentLikeState extends Equatable {
  final int likeCount;
  final bool isLiked;

  const CommentLikeState({
    required this.likeCount,
    required this.isLiked,
  });

  @override
  List<Object?> get props => [likeCount, isLiked];
}
