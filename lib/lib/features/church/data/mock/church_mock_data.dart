import 'package:faithconnect/features/church/data/models/church_profile_model.dart';

/// Static mock payloads — swap [ChurchRemoteDataSourceImpl] for API later.
abstract final class ChurchMockData {
  ChurchMockData._();

  static const _banner =
      'https://images.unsplash.com/photo-1548625145-289cb132daf4?w=1200';
  static const _avatar =
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=200';

  static const String graceCommunityId = 'grace-community';

  static ChurchProfileFeedModel profile(String profileId) {
    final now = DateTime.now();

    return ChurchProfileFeedModel(
      profile: ChurchProfileModel(
        id: profileId.isEmpty ? graceCommunityId : profileId,
        name: 'Grace Community Church',
        bio:
            'Building bridges of faith through community and compassion. Join our global family.',
        bannerUrl: _banner,
        avatarUrl: _avatar,
        isVerified: true,
        locationLabel: 'Central Park North Plaza',
        isFollowing: false,
      ),
      posts: [],
      featuredEvent: null,
    );
  }
}
