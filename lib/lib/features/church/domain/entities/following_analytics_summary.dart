import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';

class FollowingAnalyticsSummary extends Equatable {
  final GiftPeriod period;
  final int totalFollowing;
  final int previousPeriodTotal;
  final double growthPercent;
  final String periodRangeLabel;
  final List<GrowthTrendPoint> trendPoints;

  const FollowingAnalyticsSummary({
    required this.period,
    required this.totalFollowing,
    required this.previousPeriodTotal,
    required this.growthPercent,
    required this.periodRangeLabel,
    required this.trendPoints,
  });

  FollowingAnalyticsSummary copyWith({
    int? totalFollowing,
    int? previousPeriodTotal,
    List<GrowthTrendPoint>? trendPoints,
  }) {
    return FollowingAnalyticsSummary(
      period: period,
      totalFollowing: totalFollowing ?? this.totalFollowing,
      previousPeriodTotal: previousPeriodTotal ?? this.previousPeriodTotal,
      growthPercent: growthPercent,
      periodRangeLabel: periodRangeLabel,
      trendPoints: trendPoints ?? this.trendPoints,
    );
  }

  @override
  List<Object?> get props => [
        period,
        totalFollowing,
        previousPeriodTotal,
        growthPercent,
        periodRangeLabel,
        trendPoints,
      ];
}
