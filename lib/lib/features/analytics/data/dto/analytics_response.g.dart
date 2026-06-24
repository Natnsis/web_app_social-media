// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsResponse _$AnalyticsResponseFromJson(Map<String, dynamic> json) =>
    AnalyticsResponse(
      success: json['success'] as bool,
      data: AnalyticsData.fromJson(json['data'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$AnalyticsResponseToJson(AnalyticsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data.toJson(),
      'timestamp': instance.timestamp,
    };

AnalyticsData _$AnalyticsDataFromJson(Map<String, dynamic> json) =>
    AnalyticsData(
      overview: Overview.fromJson(json['overview'] as Map<String, dynamic>),
      daily: json['daily'] as List<dynamic>,
      revenue: Revenue.fromJson(json['revenue'] as Map<String, dynamic>),
      campaigns: json['campaigns'] as List<dynamic>?,
      topDonors: json['topDonors'] as List<dynamic>?,
    );

Map<String, dynamic> _$AnalyticsDataToJson(AnalyticsData instance) =>
    <String, dynamic>{
      'overview': instance.overview.toJson(),
      'daily': instance.daily,
      'revenue': instance.revenue.toJson(),
      'campaigns': instance.campaigns,
      'topDonors': instance.topDonors,
    };

Overview _$OverviewFromJson(Map<String, dynamic> json) => Overview(
  followerCount: (json['followerCount'] as num).toInt(),
  postCount: (json['postCount'] as num).toInt(),
  activeGroupCount: (json['activeGroupCount'] as num).toInt(),
  activeCampaigns: (json['activeCampaigns'] as num).toInt(),
  totalCampaignRaisedEtb: (json['totalCampaignRaisedEtb'] as num).toInt(),
  giftsReceivedCount: (json['giftsReceivedCount'] as num).toInt(),
  giftsReceivedEtb: (json['giftsReceivedEtb'] as num).toInt(),
  wallet: Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
  last30dStats: Last30dStats.fromJson(
    json['last30dStats'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$OverviewToJson(Overview instance) => <String, dynamic>{
  'followerCount': instance.followerCount,
  'postCount': instance.postCount,
  'activeGroupCount': instance.activeGroupCount,
  'activeCampaigns': instance.activeCampaigns,
  'totalCampaignRaisedEtb': instance.totalCampaignRaisedEtb,
  'giftsReceivedCount': instance.giftsReceivedCount,
  'giftsReceivedEtb': instance.giftsReceivedEtb,
  'wallet': instance.wallet.toJson(),
  'last30dStats': instance.last30dStats.toJson(),
};

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
  id: json['id'] as String,
  churchId: json['churchId'] as String,
  balanceEtb: (json['balanceEtb'] as num).toInt(),
  totalEarnedEtb: (json['totalEarnedEtb'] as num).toInt(),
  totalWithdrawnEtb: (json['totalWithdrawnEtb'] as num).toInt(),
  totalCommissionPaidEtb: (json['totalCommissionPaidEtb'] as num).toInt(),
  lastTransactionAt: json['lastTransactionAt'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'churchId': instance.churchId,
  'balanceEtb': instance.balanceEtb,
  'totalEarnedEtb': instance.totalEarnedEtb,
  'totalWithdrawnEtb': instance.totalWithdrawnEtb,
  'totalCommissionPaidEtb': instance.totalCommissionPaidEtb,
  'lastTransactionAt': instance.lastTransactionAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

Last30dStats _$Last30dStatsFromJson(Map<String, dynamic> json) => Last30dStats(
  newFollowers: (json['newFollowers'] as num).toInt(),
  postViews: (json['postViews'] as num).toInt(),
  postLikes: (json['postLikes'] as num).toInt(),
  postComments: (json['postComments'] as num).toInt(),
);

Map<String, dynamic> _$Last30dStatsToJson(Last30dStats instance) =>
    <String, dynamic>{
      'newFollowers': instance.newFollowers,
      'postViews': instance.postViews,
      'postLikes': instance.postLikes,
      'postComments': instance.postComments,
    };

Revenue _$RevenueFromJson(Map<String, dynamic> json) => Revenue(
  daily: json['daily'] as List<dynamic>,
  totals: RevenueTotals.fromJson(json['totals'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RevenueToJson(Revenue instance) => <String, dynamic>{
  'daily': instance.daily,
  'totals': instance.totals.toJson(),
};

RevenueTotals _$RevenueTotalsFromJson(Map<String, dynamic> json) =>
    RevenueTotals();

Map<String, dynamic> _$RevenueTotalsToJson(RevenueTotals instance) =>
    <String, dynamic>{};
