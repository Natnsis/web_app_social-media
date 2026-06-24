import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/new_member.dart';

class SubscribersSummary extends Equatable {
  final GiftPeriod period;
  final int totalNetwork;
  final int previousPeriodTotal;
  final double growthPercent;
  final String periodRangeLabel;
  final List<GrowthTrendPoint> trendPoints;
  final List<NewMember> newMembers;

  const SubscribersSummary({
    required this.period,
    required this.totalNetwork,
    required this.previousPeriodTotal,
    required this.growthPercent,
    required this.periodRangeLabel,
    required this.trendPoints,
    required this.newMembers,
  });

  @override
  List<Object?> get props => [
        period,
        totalNetwork,
        previousPeriodTotal,
        growthPercent,
        periodRangeLabel,
        trendPoints,
        newMembers,
      ];
}
