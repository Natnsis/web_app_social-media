import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';

abstract final class NotificationsMockData {
  NotificationsMockData._();

  static const _avatarA =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200';
  static const _avatarB =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200';
  static const _avatarC =
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=200';
  static const _avatarD =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200';
  static const _previewPost =
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400';
  static const _previewCampaign =
      'https://images.unsplash.com/photo-1519491059012-5d58061c5c42?w=400';

  static List<AppNotification> get items {
    final now = DateTime.now();

    return [
      AppNotification(
        id: 'n1',
        category: NotificationCategory.live,
        actorName: 'Grace Community',
        actorAvatarUrl: _avatarC,
        title: 'Live now',
        body: 'Sunday worship is streaming — join 2.4k viewers.',
        createdAt: now.subtract(const Duration(minutes: 4)),
        previewImageUrl: _previewPost,
        targetId: 'live-grace-sunday',
      ),
      AppNotification(
        id: 'n2',
        category: NotificationCategory.like,
        actorName: 'Sarah M.',
        actorAvatarUrl: _avatarA,
        title: 'New like',
        body: 'liked your post about Philippians 4:13.',
        createdAt: now.subtract(const Duration(minutes: 18)),
        previewImageUrl: _previewPost,
        targetId: 'post-philippians',
      ),
      AppNotification(
        id: 'n3',
        category: NotificationCategory.comment,
        actorName: 'Daniel T.',
        actorAvatarUrl: _avatarB,
        title: 'New comment',
        body: '“Amen! This verse carried me through last week.”',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: true,
        previewImageUrl: _previewPost,
        targetId: 'post-philippians',
      ),
      AppNotification(
        id: 'n4',
        category: NotificationCategory.campaign,
        actorName: 'Beza Church',
        actorAvatarUrl: _avatarC,
        title: 'Campaign milestone',
        body: 'Youth outreach fund reached 75% of its goal.',
        createdAt: now.subtract(const Duration(hours: 3)),
        previewImageUrl: _previewCampaign,
        targetId: 'campaign-youth-outreach',
      ),
      AppNotification(
        id: 'n5',
        category: NotificationCategory.follow,
        actorName: 'Hanna K.',
        actorAvatarUrl: _avatarD,
        title: 'New follower',
        body: 'started following you.',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
        targetId: 'user-hanna',
      ),
      AppNotification(
        id: 'n6',
        category: NotificationCategory.mention,
        actorName: 'Pastor Elias',
        actorAvatarUrl: _avatarB,
        title: 'Mentioned you',
        body: 'tagged you in a prayer request thread.',
        createdAt: now.subtract(const Duration(hours: 8)),
        targetId: 'post-prayer-thread',
      ),
      AppNotification(
        id: 'n7',
        category: NotificationCategory.system,
        actorName: 'FaithConnect',
        title: 'Weekly digest',
        body: 'Your community shared 48 posts and 12 live sessions.',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'n8',
        category: NotificationCategory.campaign,
        actorName: 'Hope Foundation',
        actorAvatarUrl: _avatarA,
        title: 'Donation received',
        body: 'Thank you for supporting the clean water initiative.',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        previewImageUrl: _previewCampaign,
        targetId: 'campaign-clean-water',
      ),
    ];
  }
}
