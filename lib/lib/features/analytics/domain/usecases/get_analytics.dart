// lib/features/analytics/domain/usecases/get_analytics.dart
import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/analytics/data/repositories/analytics_repository.dart';
import 'package:faithconnect/features/analytics/domain/entities/analytics_entity.dart';
import 'package:faithconnect/features/analytics/data/dto/analytics_response.dart';

class GetAnalytics {
  final AnalyticsRepository repository;

  GetAnalytics(this.repository);

  Future<Either<Failure, AnalyticsEntity>> call(String churchId) async {
    final result = await repository.getAnalytics(churchId);
    return result.map((response) => _mapToEntity(response));
  }

  AnalyticsEntity _mapToEntity(AnalyticsResponse response) {
    final overview = response.data.overview;
    final overviewEntity = OverviewEntity(
      followerCount: overview.followerCount,
      postCount: overview.postCount,
      activeGroupCount: overview.activeGroupCount,
      activeCampaigns: overview.activeCampaigns,
      totalCampaignRaisedEtb: overview.totalCampaignRaisedEtb,
      giftsReceivedCount: overview.giftsReceivedCount,
      giftsReceivedEtb: overview.giftsReceivedEtb,
      wallet: WalletEntity(
        id: overview.wallet.id,
        churchId: overview.wallet.churchId,
        balanceEtb: overview.wallet.balanceEtb,
        totalEarnedEtb: overview.wallet.totalEarnedEtb,
        totalWithdrawnEtb: overview.wallet.totalWithdrawnEtb,
        totalCommissionPaidEtb: overview.wallet.totalCommissionPaidEtb,
        lastTransactionAt: overview.wallet.lastTransactionAt,
        createdAt: overview.wallet.createdAt,
        updatedAt: overview.wallet.updatedAt,
      ),
      last30dStats: Last30dStatsEntity(
        newFollowers: overview.last30dStats.newFollowers,
        postViews: overview.last30dStats.postViews,
        postLikes: overview.last30dStats.postLikes,
        postComments: overview.last30dStats.postComments,
      ),
    );
    return AnalyticsEntity(
      overview: overviewEntity,
      daily: response.data.daily,
      revenue: RevenueEntity(
        daily: response.data.revenue.daily,
        totals: const RevenueTotalsEntity(),
      ),
      campaigns: response.data.campaigns ?? [],
      topDonors: response.data.topDonors ?? [],
    );
  }
}
