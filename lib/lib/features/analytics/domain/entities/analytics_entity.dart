// lib/features/analytics/domain/entities/analytics_entity.dart
import 'package:equatable/equatable.dart';

class AnalyticsEntity extends Equatable {
  final OverviewEntity overview;
  final List<dynamic> daily; // keep generic
  final RevenueEntity revenue;
  final List<dynamic> campaigns;
  final List<dynamic> topDonors;

  const AnalyticsEntity({
    required this.overview, 
    required this.daily, 
    required this.revenue, 
    required this.campaigns, 
    required this.topDonors
  });

  @override
  List<Object?> get props => [overview, daily, revenue, campaigns, topDonors];
}

class OverviewEntity extends Equatable {
  final int followerCount;
  final int postCount;
  final int activeGroupCount;
  final int activeCampaigns;
  final int totalCampaignRaisedEtb;
  final int giftsReceivedCount;
  final int giftsReceivedEtb;
  final WalletEntity wallet;
  final Last30dStatsEntity last30dStats;

  const OverviewEntity({
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

  @override
  List<Object?> get props => [
        followerCount,
        postCount,
        activeGroupCount,
        activeCampaigns,
        totalCampaignRaisedEtb,
        giftsReceivedCount,
        giftsReceivedEtb,
        wallet,
        last30dStats,
      ];
}

class WalletEntity extends Equatable {
  final String id;
  final String churchId;
  final int balanceEtb;
  final int totalEarnedEtb;
  final int totalWithdrawnEtb;
  final int totalCommissionPaidEtb;
  final String lastTransactionAt;
  final String createdAt;
  final String updatedAt;

  const WalletEntity({
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

  @override
  List<Object?> get props => [
        id,
        churchId,
        balanceEtb,
        totalEarnedEtb,
        totalWithdrawnEtb,
        totalCommissionPaidEtb,
        lastTransactionAt,
        createdAt,
        updatedAt,
      ];
}

class Last30dStatsEntity extends Equatable {
  final int newFollowers;
  final int postViews;
  final int postLikes;
  final int postComments;

  const Last30dStatsEntity({
    required this.newFollowers,
    required this.postViews,
    required this.postLikes,
    required this.postComments,
  });

  @override
  List<Object?> get props => [newFollowers, postViews, postLikes, postComments];
}

class RevenueEntity extends Equatable {
  final List<dynamic> daily; // placeholder
  final RevenueTotalsEntity totals;

  const RevenueEntity({required this.daily, required this.totals});

  @override
  List<Object?> get props => [daily, totals];
}

class RevenueTotalsEntity extends Equatable {
  const RevenueTotalsEntity();

  @override
  List<Object?> get props => [];
}
