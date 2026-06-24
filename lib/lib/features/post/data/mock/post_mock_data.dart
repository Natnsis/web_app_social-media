import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/post/domain/entities/post_detail.dart';

abstract final class PostMockData {
  PostMockData._();

  static const _architectureImage =
      'https://images.unsplash.com/photo-1548625145-289cb132daf4?w=900';
  static const _avatarA =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200';
  static const _avatarB =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200';

  static PostDetail detail(String postId) {
    final now = DateTime.now();
    final feedPosts = <Post>[];
    final post = feedPosts.firstWhere(
      (p) => p.id == postId,
      orElse: () => feedPosts.first,
    );

    final enriched = post.id == 'p1'
        ? Post(
            id: post.id,
            authorName: post.authorName,
            authorProfileId: post.authorProfileId,
            authorAvatarUrl: post.authorAvatarUrl,
            content:
                'Reflecting on our community gathering last night. The power of shared faith and digital connection continues to inspire our mission. Let\'s keep building bridges.',
            imageUrl: _architectureImage,
            mediaType: PostMediaType.image,
            tags: const ['#Spirituality', '#Community', '#DigitalFaith'],
            likeCount: 1200,
            commentCount: 48,
            createdAt: post.createdAt,
          )
        : post;

    return PostDetail(
      post: enriched,
      locationLabel: 'South District',
      isFollowingAuthor: false,
      comments: _comments(now),
    );
  }

  static List<PostComment> _comments(DateTime now) => [
        PostComment(
          id: 'c1',
          authorName: 'Marcus Chen',
          authorAvatarUrl: _avatarA,
          text:
              'This really resonates with me. The digital ministry outreach has been a blessing.',
          likeCount: 12,
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        PostComment(
          id: 'c2',
          authorName: 'Sarah Jenkins',
          authorAvatarUrl: _avatarB,
          text: 'Amen! Looking forward to the next gathering.',
          likeCount: 5,
          createdAt: now.subtract(const Duration(minutes: 45)),
        ),
      ];
}
