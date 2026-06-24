import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';

class LiveViewersSummary extends Equatable {
  final LiveViewersRange range;
  final int peakViewers;
  final int previousPeakViewers;
  final double growthPercent;
  final String chartSubtitle;
  final List<GrowthTrendPoint> activityPoints;
  final String averageRetention;

  const LiveViewersSummary({
    required this.range,
    required this.peakViewers,
    required this.previousPeakViewers,
    required this.growthPercent,
    required this.chartSubtitle,
    required this.activityPoints,
    required this.averageRetention,
  });

  String get comparisonLabel =>
      'Compared to $previousPeakViewers yesterday at this time';

  @override
  List<Object?> get props => [
        range,
        peakViewers,
        previousPeakViewers,
        growthPercent,
        chartSubtitle,
        activityPoints,
        averageRetention,
      ];
}
