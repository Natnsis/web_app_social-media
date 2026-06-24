import 'package:faithconnect/core/constants/sample_video_urls.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/quick_reaction.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflections_feed.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';

abstract final class ShortVideoMockData {
  ShortVideoMockData._();

  static const _worshipThumb =
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=1080';
  static const _avatar =
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=200';
  static const _avatarB =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200';

  static List<ShortVideo> videos() => [
        const ShortVideo(
          id: 'sv1',
          authorName: 'Beza International',
          authorProfileId: 'beza-international',
          authorAvatarUrl: _avatar,
          caption:
              'የእግዚአብሔር ክብር በዚህ ቦታ ነው። Powerful worship session at Beza International Church. #Worship #AddisAbaba',
          thumbnailUrl: _worshipThumb,
          videoUrl: SampleVideoUrls.shortClipA,
          audioLabel: 'Original Audio - Beza Worship Team',
          likeCount: 12400,
          reflectionCount: 856,
        ),
        const ShortVideo(
          id: 'sv2',
          authorName: 'Grace Community',
          authorProfileId: 'grace-community',
          authorAvatarUrl: _avatar,
          caption:
              'Sunday night praise — lift your voice with us. #Faith #Worship',
          thumbnailUrl:
              'https://images.unsplash.com/photo-1548625145-289cb132daf4?w=1080',
          videoUrl: SampleVideoUrls.shortClipB,
          audioLabel: 'Grace Worship Live',
          likeCount: 8200,
          reflectionCount: 412,
        ),
      ];

  static ReflectionsFeed reflections(String shortVideoId) {
    final now = DateTime.now();
    return ReflectionsFeed(
      totalReflecting: 128,
      quickReactions: const [
        QuickReaction(emoji: '🙏', label: 'Amen'),
        QuickReaction(emoji: '✨', label: 'Be Blessed'),
        QuickReaction(emoji: '🙌', label: 'ተባረኩ!'),
        QuickReaction(emoji: '🎵', label: 'Hallelujah'),
      ],
      reflections: [
        Reflection(
          id: 'r1',
          authorName: 'Selamawit T.',
          authorAvatarUrl: _avatarB,
          text:
              'This worship lifted my spirit today. Thank you for sharing this moment.',
          likeCount: 24,
          createdAt: now.subtract(const Duration(hours: 2)),
          replies: [
            Reflection(
              id: 'r1a',
              authorName: 'Daniel M.',
              authorAvatarUrl: _avatar,
              text: 'Amen! The whole team was on fire.',
              likeCount: 6,
              createdAt: now.subtract(const Duration(hours: 1)),
            ),
          ],
        ),
        Reflection(
          id: 'r2',
          authorName: 'Hanna K.',
          authorAvatarUrl: _avatar,
          text: 'Watching from Nairobi — blessings to everyone!',
          likeCount: 11,
          createdAt: now.subtract(const Duration(minutes: 40)),
        ),
      ],
    );
  }
}
