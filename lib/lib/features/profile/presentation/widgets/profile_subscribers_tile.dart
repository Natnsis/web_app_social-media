import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileSubscribersTile extends StatelessWidget {
  final ProfileStats stats;
  final VoidCallback onTap;

  const ProfileSubscribersTile({
    super.key,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileStatCard(
      icon: Iconsax.user_add,
      value: formatCount(stats.subscriberCount),
      trendText:
          '+${stats.subscriberGrowthPercent.toStringAsFixed(0)}% this week',
      onTap: onTap,
    );
  }
}
