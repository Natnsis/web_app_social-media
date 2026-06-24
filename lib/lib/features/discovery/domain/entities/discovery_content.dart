import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_live_item.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_campaign.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_suggested_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_trending_profile.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_meta.dart';

class DiscoveryContent extends Equatable {
  final List<DiscoveryNearbyChurch> nearby;
  final List<DiscoveryLiveItem> liveNow;
  final List<DiscoveryTrendingProfile> trending;
  final List<DiscoverySuggestedChurch> suggested;
  final List<DiscoveryCampaign> campaigns;

  const DiscoveryContent({
    required this.nearby,
    required this.liveNow,
    required this.trending,
    required this.suggested,
    required this.campaigns,
  });

  @override
  List<Object?> get props =>
      [nearby, liveNow, trending, suggested, campaigns];
}

class NearbyChurchesResult extends Equatable {
  final String areaLabel;
  final int totalCount;
  final List<DiscoveryNearbyChurch> churches;
  final NearbyChurchesFilter filter;
  final NearbyChurchesMeta? meta;

  const NearbyChurchesResult({
    required this.areaLabel,
    required this.totalCount,
    required this.churches,
    this.filter = const NearbyChurchesFilter(),
    this.meta,
  });

  NearbyChurchesResult copyWith({
    String? areaLabel,
    int? totalCount,
    List<DiscoveryNearbyChurch>? churches,
    NearbyChurchesFilter? filter,
    NearbyChurchesMeta? meta,
  }) {
    return NearbyChurchesResult(
      areaLabel: areaLabel ?? this.areaLabel,
      totalCount: totalCount ?? this.totalCount,
      churches: churches ?? this.churches,
      filter: filter ?? this.filter,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [areaLabel, totalCount, churches, filter, meta];
}
