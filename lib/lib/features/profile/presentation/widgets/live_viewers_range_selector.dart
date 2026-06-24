import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_pill_segment_selector.dart';
import 'package:flutter/material.dart';

class LiveViewersRangeSelector extends StatelessWidget {
  final LiveViewersRange selected;
  final ValueChanged<LiveViewersRange> onChanged;

  const LiveViewersRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _ranges = LiveViewersRange.values;

  @override
  Widget build(BuildContext context) {
    return ProfilePillSegmentSelector(
      labels: _ranges.map((r) => r.label).toList(),
      selectedIndex: _ranges.indexOf(selected),
      onChanged: (index) => onChanged(_ranges[index]),
    );
  }
}
