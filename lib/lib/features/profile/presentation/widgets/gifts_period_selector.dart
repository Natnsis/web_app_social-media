import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_pill_segment_selector.dart';
import 'package:flutter/material.dart';

class GiftsPeriodSelector extends StatelessWidget {
  final GiftPeriod selected;
  final ValueChanged<GiftPeriod> onChanged;

  const GiftsPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _periods = GiftPeriod.values;

  @override
  Widget build(BuildContext context) {
    return ProfilePillSegmentSelector(
      labels: _periods.map((p) => p.label).toList(),
      selectedIndex: _periods.indexOf(selected),
      onChanged: (index) => onChanged(_periods[index]),
    );
  }
}
