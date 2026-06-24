import 'package:dio/dio.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/campaign/data/dto/campaign_api_dto.dart';
import 'package:faithconnect/features/church/data/datasources/church_remote_datasource.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_campaign.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_live_item.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_meta.dart' as domain_meta;
import 'package:faithconnect/features/discovery/domain/entities/discovery_suggested_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_trending_profile.dart';

abstract class DiscoveryRemoteDataSource {
  Future<DiscoveryContent> fetchDiscoveryContent({
    NearbyChurchesFilter nearbyFilter = const NearbyChurchesFilter(),
  });

  Future<NearbyChurchesResult> fetchNearbyChurches({
    NearbyChurchesFilter filter = const NearbyChurchesFilter(),
  });

  Future<void> toggleFollowChurch({
    required String churchId,
    required bool follow,
  });
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSourceImpl({
    required ChurchRemoteDataSource churchRemote,
    required Dio dio,
  })  : _churchRemote = churchRemote,
        _dio = dio;

  final ChurchRemoteDataSource _churchRemote;
  final Dio _dio;

  @override
  Future<DiscoveryContent> fetchDiscoveryContent({
    NearbyChurchesFilter nearbyFilter = const NearbyChurchesFilter(),
  }) async {
    final churchesPage = await _churchRemote.fetchChurches(limit: 20);
    final suggested =
        churchesPage.churches.map((c) => c.toSuggestedChurch()).toList();

    final campaigns = await _fetchCampaigns();

    return DiscoveryContent(
      nearby: const [],
      liveNow: const [],
      trending: const [],
      suggested: suggested,
      campaigns: campaigns,
    );
  }

  @override
  Future<NearbyChurchesResult> fetchNearbyChurches({
    NearbyChurchesFilter filter = const NearbyChurchesFilter(),
  }) async {
    final page = await _churchRemote.fetchNearbyChurches(filter);

    final churches = page.churches
        .map((dto) => dto.toNearbyChurch(isFollowing: dto.isFollowingByMe))
        .toList();

    return NearbyChurchesResult(
      areaLabel: _areaLabel(filter, page, churches),
      totalCount: page.meta.pagination.total,
      churches: churches,
      filter: filter,
      meta: domain_meta.NearbyChurchesMeta(
        page: page.meta.pagination.page,
        limit: page.meta.pagination.limit,
        total: page.meta.pagination.total,
        totalPages: page.meta.pagination.totalPages,
        hasNextPage: page.meta.pagination.hasNextPage,
        hasPreviousPage: page.meta.pagination.hasPreviousPage,
        center: page.meta.center != null 
            ? domain_meta.LatLngModel(latitude: page.meta.center!.latitude, longitude: page.meta.center!.longitude) 
            : null,
        radiusKm: page.meta.radiusKm,
      ),
    );
  }

  Future<List<DiscoveryCampaign>> _fetchCampaigns() async {
    try {
      final response = await _dio.get<dynamic>('/v1/campaigns');
      
      final parsed = ApiListResponse.parse(
        response.data,
        CampaignApiDto.fromJson,
      );

      return parsed.data
          .where((c) => c.id.isNotEmpty)
          .map((c) => DiscoveryCampaign(
            id: c.id,
            title: c.title,
            organizationName: c.organizationName ?? 'Church',
            raisedAmountEtb: c.raisedAmountEtb,
            goalAmountEtb: c.goalAmountEtb,
            daysLeft: c.daysLeft ?? 0,
            imageUrl: c.imageUrl,
          ))
          .toList();
    } catch (e) {
      // Return empty list on failure so the rest of the discovery page loads
      return const [];
    }
  }

  @override
  Future<void> toggleFollowChurch({
    required String churchId,
    required bool follow,
  }) async {
    await _churchRemote.toggleFollowChurch(
      churchId: churchId,
      
      follow: follow,
    );
  }

  String _areaLabel(
    NearbyChurchesFilter filter,
    NearbyChurchesPageResult page,
    List<DiscoveryNearbyChurch> churches,
  ) {
    if (churches.isNotEmpty) {
      final first = churches.first;
      final city = first.city ?? first.location?.split(',').last.trim() ?? '';
      if (city.isNotEmpty) {
        return '$city · within ${filter.clampedRadiusKm} km';
      }
    }

    final radius = page.meta.radiusKm ?? filter.clampedRadiusKm;
    return 'Within ${radius.round()} km';
  }

}
