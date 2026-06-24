import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_group.dart';
import 'package:faithconnect/features/home/domain/entities/featured_event.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';

class ChurchProfile extends Equatable {
  final String id;
  final String name;
  final String bio;
  final String? bannerUrl;
  final String? avatarUrl;
  final bool isVerified;
  final String? locationLabel;
  final bool isFollowing;

  const ChurchProfile({
    required this.id,
    required this.name,
    required this.bio,
    this.bannerUrl,
    this.avatarUrl,
    this.isVerified = false,
    this.locationLabel,
    this.isFollowing = false,
  });

  ChurchProfile copyWith({bool? isFollowing}) {
    return ChurchProfile(
      id: id,
      name: name,
      bio: bio,
      bannerUrl: bannerUrl,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      locationLabel: locationLabel,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        bio,
        bannerUrl,
        avatarUrl,
        isVerified,
        locationLabel,
        isFollowing,
      ];
}

class ChurchProfileFeed extends Equatable {
  final ChurchProfile profile;
  final List<Post> posts;
  final List<Campaign> campaigns;
  final List<ChurchProfileGroup> groups;
  final List<ChurchMember> members;
  final FeaturedEvent? featuredEvent;

  const ChurchProfileFeed({
    required this.profile,
    required this.posts,
    this.campaigns = const [],
    this.groups = const [],
    this.members = const [],
    this.featuredEvent,
  });

  ChurchProfileFeed copyWith({
    ChurchProfile? profile,
    List<Post>? posts,
    List<Campaign>? campaigns,
    List<ChurchProfileGroup>? groups,
    List<ChurchMember>? members,
    FeaturedEvent? featuredEvent,
  }) {
    return ChurchProfileFeed(
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      campaigns: campaigns ?? this.campaigns,
      groups: groups ?? this.groups,
      members: members ?? this.members,
      featuredEvent: featuredEvent ?? this.featuredEvent,
    );
  }

  @override
  List<Object?> get props =>
      [profile, posts, campaigns, groups, members, featuredEvent];
}
