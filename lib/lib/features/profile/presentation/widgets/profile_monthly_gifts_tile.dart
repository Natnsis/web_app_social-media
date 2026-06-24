import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Hub metric row using the shared [ProfileStatCard] layout.
class ProfileMonthlyGiftsTile extends StatelessWidget {
  final ProfileStats stats;
  final VoidCallback onTap;

  const ProfileMonthlyGiftsTile({
    super.key,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileStatCard(
      icon: Iconsax.chart_2,
      value: formatCurrencyEtb(stats.monthlyGiftsTotal),
      trendText:
          '+${stats.monthlyGiftsGrowthPercent.toStringAsFixed(0)}% this month',
      onTap: onTap,
    );
  }
}
