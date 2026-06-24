import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_spline_area_chart_card.dart';
import 'package:flutter/material.dart';

class GiftsGrowthChartCard extends StatelessWidget {
  final GiftSummary summary;

  const GiftsGrowthChartCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return ProfileSplineAreaChartCard(
      title: 'Growth Trend',
      trailingLabel: summary.periodRangeLabel,
      points: summary.trendPoints,
      tooltipFormat: 'point.y ETB',
      chartKeySuffix: 'gifts-${summary.period.name}',
    );
  }
}
