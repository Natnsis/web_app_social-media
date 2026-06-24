import 'package:faithconnect/features/church/data/models/church_profile_model.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';

/// Maps church profile API data to [OrganizationProfile] for the account hub.
abstract final class OrganizationProfileMapper {
  OrganizationProfileMapper._();

  static OrganizationProfile fromChurchFeed(
    ChurchProfileFeedModel feed, {
    List<ProfileShortClip> shorts = const [],
  }) {
    final profile = feed.profile;
    final owner = _resolveOwner(feed.members);

    return OrganizationProfile(
      id: profile.id,
      name: profile.name,
      hubLabel: _hubLabel(profile.locationLabel, profile.bio),
      avatarUrl: profile.avatarUrl,
      owner: owner,
      stats: ProfileStats(
        subscriberCount: feed.followerCount,
        subscriberGrowthPercent: 0,
        campaignCount: feed.campaignCount,
        campaignGrowthPercent: 0,
        monthlyGiftsTotal: 0,
        monthlyGiftsGrowthPercent: 0,
        livePeakViewers: 0,
        liveGrowthPercent: 0,
      ),
      shorts: shorts,
    );
  }

  static OrganizationProfile personalFallback() {
    return const OrganizationProfile(
      id: 'personal',
      name: 'My Account',
      hubLabel: 'Personal profile',
      owner: ProfileOwner(name: 'Member', role: 'Member'),
      stats: ProfileStats(
        subscriberCount: 0,
        subscriberGrowthPercent: 0,
        campaignCount: 0,
        campaignGrowthPercent: 0,
        monthlyGiftsTotal: 0,
        monthlyGiftsGrowthPercent: 0,
        livePeakViewers: 0,
        liveGrowthPercent: 0,
      ),
    );
  }

  static ProfileOwner _resolveOwner(List<ChurchMember> members) {
    for (final member in members) {
      if (member.role?.toLowerCase() == 'owner') {
        return ProfileOwner(
          name: member.name,
          role: member.role ?? 'Owner',
          avatarUrl: member.avatarUrl,
        );
      }
    }

    if (members.isNotEmpty) {
      final member = members.first;
      return ProfileOwner(
        name: member.name,
        role: member.role ?? 'Administrator',
        avatarUrl: member.avatarUrl,
      );
    }

    return const ProfileOwner(name: 'Church Owner', role: 'Administrator');
  }

  static String _hubLabel(String? locationLabel, String bio) {
    final location = locationLabel?.trim();
    if (location != null && location.isNotEmpty) {
      return location;
    }

    final trimmedBio = bio.trim();
    if (trimmedBio.isNotEmpty) {
      return trimmedBio.length <= 48
          ? trimmedBio
          : '${trimmedBio.substring(0, 45)}...';
    }

    return 'Ministry hub';
  }
}
