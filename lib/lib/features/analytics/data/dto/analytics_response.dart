// lib/features/analytics/data/dto/analytics_response.dart
import 'package:json_annotation/json_annotation.dart';
part 'analytics_response.g.dart';


@JsonSerializable(explicitToJson: true)
class AnalyticsResponse {
  final bool success;
  final AnalyticsData data;
  final String timestamp;

  AnalyticsResponse({required this.success, required this.data, required this.timestamp});

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) => _$AnalyticsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsResponseToJson(this);
}


@JsonSerializable(explicitToJson: true)
class AnalyticsData {
  final Overview overview;
  final List<dynamic> daily; // generic for now
  final Revenue revenue;
  final List<dynamic>? campaigns;
  final List<dynamic>? topDonors;

  AnalyticsData({required this.overview, required this.daily, required this.revenue, this.campaigns, this.topDonors});

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => _$AnalyticsDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsDataToJson(this);
}


@JsonSerializable(explicitToJson: true)
class Overview {
  final int followerCount;
  final int postCount;
  final int activeGroupCount;
  final int activeCampaigns;
  final int totalCampaignRaisedEtb;
  final int giftsReceivedCount;
  final int giftsReceivedEtb;
  final Wallet wallet;
  final Last30dStats last30dStats;

  Overview({
    required this.followerCount,
    required this.postCount,
    required this.activeGroupCount,
    required this.activeCampaigns,
    required this.totalCampaignRaisedEtb,
    required this.giftsReceivedCount,
    required this.giftsReceivedEtb,
    required this.wallet,
    required this.last30dStats,
  });

  factory Overview.fromJson(Map<String, dynamic> json) => _$OverviewFromJson(json);

  Map<String, dynamic> toJson() => _$OverviewToJson(this);
}

@JsonSerializable(explicitToJson: true)
@JsonSerializable(explicitToJson: true)
class Wallet {
  final String id;
  final String churchId;
  final int balanceEtb;
  final int totalEarnedEtb;
  final int totalWithdrawnEtb;
  final int totalCommissionPaidEtb;
  final String lastTransactionAt;
  final String createdAt;
  final String updatedAt;

  Wallet({
    required this.id,
    required this.churchId,
    required this.balanceEtb,
    required this.totalEarnedEtb,
    required this.totalWithdrawnEtb,
    required this.totalCommissionPaidEtb,
    required this.lastTransactionAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);
}


@JsonSerializable(explicitToJson: true)
class Last30dStats {
  final int newFollowers;
  final int postViews;
  final int postLikes;
  final int postComments;

  Last30dStats({
    required this.newFollowers,
    required this.postViews,
    required this.postLikes,
    required this.postComments,
  });

  factory Last30dStats.fromJson(Map<String, dynamic> json) => _$Last30dStatsFromJson(json);

  Map<String, dynamic> toJson() => _$Last30dStatsToJson(this);
}

@JsonSerializable(explicitToJson: true)
@JsonSerializable(explicitToJson: true)
class Revenue {
  final List<dynamic> daily; // placeholder
  final RevenueTotals totals;

  Revenue({required this.daily, required this.totals});

  factory Revenue.fromJson(Map<String, dynamic> json) => _$RevenueFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueToJson(this);
}


@JsonSerializable()
class RevenueTotals {
  // Placeholder fields can be added later
  RevenueTotals();

  factory RevenueTotals.fromJson(Map<String, dynamic> json) => _$RevenueTotalsFromJson(json);
  Map<String, dynamic> toJson() => _$RevenueTotalsToJson(this);
}

// Run `flutter pub run build_runner build` to generate *.g.dart files.
