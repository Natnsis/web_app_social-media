import 'package:faithconnect/features/church/data/dto/church_api_dto.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/home/data/models/post_model.dart';

class ChurchProfileModel extends ChurchProfile {
  const ChurchProfileModel({
    required super.id,
    required super.name,
    required super.bio,
    super.bannerUrl,
    super.avatarUrl,
    super.isVerified,
    super.locationLabel,
    super.isFollowing,
  });

  factory ChurchProfileModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('verificationStatus') ||
        json.containsKey('logoUrl')) {
      return ChurchApiDto.fromJson(json).toProfileModel(
        isFollowing: json['is_following'] as bool? ?? false,
      );
    }
    return ChurchProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      bio: json['bio'] as String? ?? json['description'] as String? ?? '',
      bannerUrl: json['banner_url'] as String? ?? json['coverImageUrl'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['logoUrl'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      locationLabel: json['location_label'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  ChurchProfile toEntity() => ChurchProfile(
        id: id,
        name: name,
        bio: bio,
        bannerUrl: bannerUrl,
        avatarUrl: avatarUrl,
        isVerified: isVerified,
        locationLabel: locationLabel,
        isFollowing: isFollowing,
      );
}

class ChurchProfileFeedModel extends ChurchProfileFeed {
  final int followerCount;
  final int campaignCount;

  const ChurchProfileFeedModel({
    required super.profile,
    required super.posts,
    super.campaigns,
    super.groups,
    super.members,
    super.featuredEvent,
    this.followerCount = 0,
    this.campaignCount = 0,
  });

  ChurchProfileFeed toEntity() => ChurchProfileFeed(
        profile: (profile as ChurchProfileModel).toEntity(),
        posts: posts.map((p) => (p as PostModel).toEntity()).toList(),
        campaigns: campaigns,
        groups: groups,
        members: members,
        featuredEvent: featuredEvent,
      );
}
