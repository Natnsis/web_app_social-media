import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/campaign/data/dto/campaign_api_dto.dart';
import 'package:faithconnect/features/home/data/models/home_feed_model.dart';
import 'package:faithconnect/features/home/data/models/post_model.dart';
import 'package:faithconnect/features/post/data/datasources/posts_remote_datasource.dart';
import 'package:faithconnect/features/post/domain/entities/posts_query_filter.dart';
import 'package:faithconnect/features/scripture/data/datasources/scripture_remote_datasource.dart';
import 'package:faithconnect/features/scripture/data/mappers/scryper_mapper.dart';
import 'package:faithconnect/features/live_streaming/data/models/live_stream_model.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';

abstract class HomeRemoteDataSource {
  Future<HomeFeedModel> getFeed();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({
    required Dio dio,
    required PostsRemoteDataSource postsRemote,
    required ScriptureRemoteDataSource scriptureRemote,
  })  : _dio = dio,
        _postsRemote = postsRemote,
        _scriptureRemote = scriptureRemote;

  final Dio _dio;
  final PostsRemoteDataSource _postsRemote;
  final ScriptureRemoteDataSource _scriptureRemote;

  static const _defaultVerse = DailyVerseModel(
    quote: 'Be still, and know that I am God.',
    reference: 'Psalm 46:10',
    subtitle: 'Meditate on peace today.',
  );

  @override
  Future<HomeFeedModel> getFeed() async {
    final results = await Future.wait([
      _fetchPosts(),
      _fetchCampaigns(),
      _fetchLiveStreams(),
    ]);

    final posts = results[0] as List<PostModel>;
    final campaigns = results[1] as List<CampaignApiDto>;
    final streams = results[2] as List<LiveStreamModel>;
    final dailyVerses = await _fetchDailyVerses();

    final liveNowItems = streams.map((stream) {
      return LiveNowItemModel(
        id: stream.id,
        name: stream.displayOrganization,
        avatarUrl: stream.hostAvatarUrl,
        isLive: stream.status != LiveStreamStatus.ended,
        streamId: stream.id,
      );
    }).toList();

    return HomeFeedModel(
      liveNow: liveNowItems,
      dailyVerse: dailyVerses.first,
      dailyVerses: dailyVerses,
      posts: posts,
      featuredEvent: _pickFeaturedEvent(campaigns),
    );
  }

  Future<List<DailyVerseModel>> _fetchDailyVerses() async {
    try {
      final scrypers = await _scriptureRemote.fetchScrypers();
      final verses = ScryperMapper.toDailyVerseModels(scrypers);
      if (verses.isNotEmpty) return verses;
    } catch (_) {}

    return const [_defaultVerse];
  }

  FeaturedEventModel _pickFeaturedEvent(List<CampaignApiDto> campaigns) {
    for (final campaign in campaigns) {
      final event = campaign.toFeaturedEventModel();
      if (event != null) return event;
    }
    return const FeaturedEventModel(
      id: 'community',
      title: 'Support a campaign',
      description: 'Browse active campaigns from churches near you.',
      dateTime: 'Open the Campaigns tab',
      location: '',
    );
  }

  Future<List<PostModel>> _fetchPosts() async {
    try {
      final page = await _postsRemote.fetchPosts(
        filter: PostsQueryFilter.defaults(),
      );
      return page.posts;
    } catch (_) {
      return const [];
    }
  }

  Future<List<CampaignApiDto>> _fetchCampaigns() async {
    try {
      final response = await _dio.get<dynamic>(
        CampaignsApiEndpoint.list,
        queryParameters: {'page': 1, 'limit': 10},
      );

      final parsed = ApiListResponse.parse(
        response.data,
        CampaignApiDto.fromJson,
      );

      return parsed.data.where((c) => c.id.isNotEmpty).toList();
    } on DioException {
      return const [];
    }
  }

  Future<List<LiveStreamModel>> _fetchLiveStreams() async {
    try {
      final response = await _dio.get<dynamic>(
        LiveStreamApiEndpoint.list,
      );
      if (response.statusCode == 200) {
        final rawData = response.data['data'];
        final List<dynamic> list;
        if (rawData is Map && rawData['data'] is List) {
          list = rawData['data'] as List;
        } else if (rawData is List) {
          list = rawData;
        } else {
          list = [];
        }
        return list.map((e) => LiveStreamModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
