import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileCampaignsTile extends StatelessWidget {
  final ProfileStats stats;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileCampaignsTile({
    super.key,
    required this.stats,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileStatCard(
      icon: Iconsax.heart,
      value: stats.campaignCount.toString(),
      trendText:
          '+${stats.campaignGrowthPercent.toStringAsFixed(0)}% this month',
      trailing: trailing,
      onTap: onTap,
    );
  }
}
