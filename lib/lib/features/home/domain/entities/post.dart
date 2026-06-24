import 'package:equatable/equatable.dart';

enum PostMediaType { text, image, video }

class Post extends Equatable {
  final String id;
  final String authorName;
  final String? authorProfileId;
  final String? authorAvatarUrl;
  final String content;
  final String? imageUrl;
  final PostMediaType mediaType;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final bool? _isLiked;
  final bool? _isOwnedByMe;
  final bool? _isSaved;
  final String? watchedByLabel;

  bool get isLiked => _isLiked ?? false;
  bool get isOwnedByMe => _isOwnedByMe ?? false;
  bool get isSaved => _isSaved ?? false;
  final String? timeAgoLabel;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.authorName,
    this.authorProfileId,
    this.authorAvatarUrl,
    required this.content,
    this.imageUrl,
    this.mediaType = PostMediaType.text,
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    bool? isLiked,
    bool? isOwnedByMe,
    bool? isSaved,
    this.watchedByLabel,
    this.timeAgoLabel,
    required this.createdAt,
  })  : _isLiked = isLiked,
        _isOwnedByMe = isOwnedByMe,
        _isSaved = isSaved;

  Post copyWith({
    String? content,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isOwnedByMe,
    bool? isSaved,
  }) {
    return Post(
      id: id,
      authorName: authorName,
      authorProfileId: authorProfileId,
      authorAvatarUrl: authorAvatarUrl,
      content: content ?? this.content,
      imageUrl: imageUrl,
      mediaType: mediaType,
      tags: tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? _isLiked,
      isOwnedByMe: isOwnedByMe ?? _isOwnedByMe,
      isSaved: isSaved ?? _isSaved,
      watchedByLabel: watchedByLabel,
      timeAgoLabel: timeAgoLabel,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorProfileId,
        authorAvatarUrl,
        content,
        imageUrl,
        mediaType,
        tags,
        likeCount,
        commentCount,
        _isLiked,
        _isOwnedByMe,
        _isSaved,
        watchedByLabel,
        timeAgoLabel,
        createdAt,
      ];
}
