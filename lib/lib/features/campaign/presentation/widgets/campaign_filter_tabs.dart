import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';
import 'package:flutter/material.dart';

class CampaignFilterTabs extends StatelessWidget {
  final CampaignHubFilter selected;
  final ValueChanged<CampaignHubFilter> onChanged;

  const CampaignFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = CampaignHubFilter.values;
    final labels = filters.map((f) => f.label).toList();
    final index = filters.indexOf(selected).clamp(0, filters.length - 1);

    return CustomPillTabBar(
      labels: labels,
      selectedIndex: index,
      onTabSelected: (i) => onChanged(filters[i]),
    );
  }
}
