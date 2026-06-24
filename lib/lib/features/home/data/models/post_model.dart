import 'package:faithconnect/features/home/domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorName,
    super.authorProfileId,
    super.authorAvatarUrl,
    required super.content,
    super.imageUrl,
    super.mediaType,
    super.tags,
    super.likeCount,
    super.commentCount,
    super.isLiked,
    super.isOwnedByMe,
    super.isSaved,
    super.watchedByLabel,
    super.timeAgoLabel,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final media = json['media_type'] as String? ?? 'text';
    return PostModel(
      id: json['id']?.toString() ?? '',
      authorName: json['author_name'] as String? ?? '',
      authorProfileId: json['author_profile_id'] as String?,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      mediaType: switch (media) {
        'image' => PostMediaType.image,
        'video' => PostMediaType.video,
        _ => PostMediaType.text,
      },
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] == true,
      isOwnedByMe: json['is_owned_by_me'] == true,
      isSaved: json['is_saved'] == true,
      watchedByLabel: json['watched_by_label'] as String?,
      timeAgoLabel: json['time_ago_label'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Post toEntity() => Post(
        id: id,
        authorName: authorName,
        authorProfileId: authorProfileId,
        authorAvatarUrl: authorAvatarUrl,
        content: content,
        imageUrl: imageUrl,
        mediaType: mediaType,
        tags: tags,
        likeCount: likeCount,
        commentCount: commentCount,
        isLiked: isLiked,
        isOwnedByMe: isOwnedByMe,
        isSaved: isSaved,
        watchedByLabel: watchedByLabel,
        timeAgoLabel: timeAgoLabel,
        createdAt: createdAt,
      );
}
