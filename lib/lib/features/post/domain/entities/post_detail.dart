import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';

class PostDetail extends Equatable {
  final Post post;
  final String? locationLabel;
  final bool isFollowingAuthor;
  final bool isLiked;
  final bool isSaved;
  final List<PostComment> comments;

  const PostDetail({
    required this.post,
    this.locationLabel,
    this.isFollowingAuthor = false,
    this.isLiked = false,
    this.isSaved = false,
    this.comments = const [],
  });

  PostDetail copyWith({
    Post? post,
    String? locationLabel,
    bool? isFollowingAuthor,
    bool? isLiked,
    bool? isSaved,
    List<PostComment>? comments,
  }) {
    return PostDetail(
      post: post ?? this.post,
      locationLabel: locationLabel ?? this.locationLabel,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
        post,
        locationLabel,
        isFollowingAuthor,
        isLiked,
        isSaved,
        comments,
      ];
}
