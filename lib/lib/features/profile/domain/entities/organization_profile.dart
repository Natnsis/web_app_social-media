import 'package:equatable/equatable.dart';

class OrganizationProfile extends Equatable {
  final String id;
  final String name;
  final String hubLabel;
  final String? avatarUrl;
  final String? bannerAssetPath;
  final ProfileOwner owner;
  final ProfileStats stats;
  final List<ProfileShortClip> shorts;

  const OrganizationProfile({
    required this.id,
    required this.name,
    required this.hubLabel,
    this.avatarUrl,
    this.bannerAssetPath,
    required this.owner,
    required this.stats,
    this.shorts = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        hubLabel,
        avatarUrl,
        bannerAssetPath,
        owner,
        stats,
        shorts,
      ];
}

class ProfileShortClip extends Equatable {
  final String id;
  final String title;
  final String thumbnailUrl;
  final int viewCount;

  const ProfileShortClip({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.viewCount,
  });

  ProfileShortClip copyWith({
    String? title,
    String? thumbnailUrl,
    int? viewCount,
  }) {
    return ProfileShortClip(
      id: id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  List<Object?> get props => [id, title, thumbnailUrl, viewCount];
}

class ProfileOwner extends Equatable {
  final String name;
  final String role;
  final String? avatarUrl;

  const ProfileOwner({
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, role, avatarUrl];
}

class ProfileStats extends Equatable {
  final int subscriberCount;
  final double subscriberGrowthPercent;
  final int campaignCount;
  final double campaignGrowthPercent;
  final double monthlyGiftsTotal;
  final double monthlyGiftsGrowthPercent;
  final int livePeakViewers;
  final double liveGrowthPercent;

  const ProfileStats({
    required this.subscriberCount,
    required this.subscriberGrowthPercent,
    required this.campaignCount,
    required this.campaignGrowthPercent,
    required this.monthlyGiftsTotal,
    required this.monthlyGiftsGrowthPercent,
    required this.livePeakViewers,
    required this.liveGrowthPercent,
  });

  @override
  List<Object?> get props => [
        subscriberCount,
        subscriberGrowthPercent,
        campaignCount,
        campaignGrowthPercent,
        monthlyGiftsTotal,
        monthlyGiftsGrowthPercent,
        livePeakViewers,
        liveGrowthPercent,
      ];
}
