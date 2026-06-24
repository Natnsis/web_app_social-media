import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/campaign/data/datasources/campaign_remote_datasource.dart';
import 'package:faithconnect/features/campaign/domain/entities/following_campaigns_query_filter.dart';
import 'package:faithconnect/features/church/data/datasources/church_remote_datasource.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_ids.dart';
import 'package:faithconnect/features/post/data/datasources/posts_remote_datasource.dart';
import 'package:faithconnect/features/post/domain/entities/posts_query_filter.dart';
import 'package:faithconnect/features/profile/data/mappers/organization_profile_mapper.dart';
import 'package:faithconnect/features/profile/data/mappers/profile_short_clip_mapper.dart';
import 'package:faithconnect/features/profile/data/mock/profile_mock_data.dart';
import 'package:faithconnect/features/profile/domain/entities/account_profile_content.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';
import 'package:faithconnect/features/shortvideo/data/datasources/short_video_remote_datasource.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/shorts_query_filter.dart';

import 'package:faithconnect/features/event/data/datasources/event_remote_datasource.dart';
import 'package:faithconnect/features/event/domain/entities/events_query_filter.dart';

abstract class ProfileRemoteDataSource {
  Future<OrganizationProfile> fetchOrganizationProfile();

  Future<AccountProfileContent> fetchAccountProfileContent({
    required bool churchMode,
  });

  Future<GiftSummary> fetchGiftSummary(GiftPeriod period);

  Future<SubscribersSummary> fetchSubscribersSummary(GiftPeriod period);

  Future<LiveViewersSummary> fetchLiveViewersSummary(LiveViewersRange range);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({
    required ChurchRemoteDataSource churchRemote,
    required PostsRemoteDataSource postsRemote,
    required ShortVideoRemoteDataSource shortsRemote,
    required EventRemoteDataSource eventRemote,
    required CampaignRemoteDataSource campaignRemote,
  })  : _churchRemote = churchRemote,
        _postsRemote = postsRemote,
        _shortsRemote = shortsRemote,
        _eventRemote = eventRemote,
        _campaignRemote = campaignRemote;

  final ChurchRemoteDataSource _churchRemote;
  final PostsRemoteDataSource _postsRemote;
  final ShortVideoRemoteDataSource _shortsRemote;
  final EventRemoteDataSource _eventRemote;
  final CampaignRemoteDataSource _campaignRemote;

  static const _contentQuery = PostsQueryFilter(page: 1, limit: 50);
  static const _shortsQuery = ShortsQueryFilter(page: 1, limit: 50);

  @override
  Future<OrganizationProfile> fetchOrganizationProfile() async {
    try {
      final feed = await _churchRemote.getChurchProfile(ChurchProfileIds.me);
      final shorts = await _fetchShortClips(churchId: feed.profile.id);
      return OrganizationProfileMapper.fromChurchFeed(feed, shorts: shorts);
    } on AuthException {
      return OrganizationProfileMapper.personalFallback();
    }
  }

  @override
  Future<AccountProfileContent> fetchAccountProfileContent({
    required bool churchMode,
  }) async {
    if (churchMode) {
      return _fetchChurchContent();
    }
    return _fetchMemberSavedContent();
  }

  Future<AccountProfileContent> _fetchChurchContent() async {
    final feed = await _churchRemote.getChurchProfile(ChurchProfileIds.me);
    final churchId = feed.profile.id;
    final shorts = await _fetchShortClips(churchId: churchId);
    
    final postsResult = await _postsRemote.fetchPosts(
      filter: const PostsQueryFilter(),
    );

    final campaigns = await _campaignRemote.fetchCampaigns(
      filter: const FollowingCampaignsQueryFilter(),
    );

    final events = await _eventRemote.fetchEvents(
      filter: const EventsQueryFilter(),
    );

    return AccountProfileContent.fromPosts(
      postsResult.posts,
      shorts: shorts,
      campaigns: campaigns,
      events: events,
    );
  }

  Future<AccountProfileContent> _fetchMemberSavedContent() async {
    final savedPage = await _postsRemote.fetchSavedPosts(filter: _contentQuery);
    final shorts = await _fetchShortClips();

    return AccountProfileContent.fromPosts(savedPage.posts, shorts: shorts);
  }

  Future<List<ProfileShortClip>> _fetchShortClips({String? churchId}) async {
    final shorts = await _shortsRemote.getShortVideos(filter: _shortsQuery);
    final normalizedChurchId = churchId?.trim();

    if (normalizedChurchId == null || normalizedChurchId.isEmpty) {
      return shorts.map(ProfileShortClipMapper.fromShortVideo).toList();
    }

    return shorts
        .where(
          (short) =>
              short.authorProfileId != null &&
              short.authorProfileId == normalizedChurchId,
        )
        .map(ProfileShortClipMapper.fromShortVideo)
        .toList();
  }

  @override
  Future<GiftSummary> fetchGiftSummary(GiftPeriod period) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ProfileMockData.giftSummary(period);
  }

  @override
  Future<SubscribersSummary> fetchSubscribersSummary(GiftPeriod period) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ProfileMockData.subscribersSummary(period);
  }

  @override
  Future<LiveViewersSummary> fetchLiveViewersSummary(
    LiveViewersRange range,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return ProfileMockData.liveViewersSummary(range);
  }
}
