import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_transaction.dart';

class GiftSummary extends Equatable {
  final GiftPeriod period;
  final double totalAmount;
  final double growthPercent;
  final String periodRangeLabel;
  final List<GrowthTrendPoint> trendPoints;
  final List<GiftTransaction> recentTransactions;

  const GiftSummary({
    required this.period,
    required this.totalAmount,
    required this.growthPercent,
    required this.periodRangeLabel,
    required this.trendPoints,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        period,
        totalAmount,
        growthPercent,
        periodRangeLabel,
        trendPoints,
        recentTransactions,
      ];
}

class GrowthTrendPoint extends Equatable {
  final String label;
  final double value;

  const GrowthTrendPoint({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}
