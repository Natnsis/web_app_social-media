import 'package:faithconnect/features/campaign/presentation/navigation/campaign_navigation.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_campaign.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_campaign_card.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscoveryCampaignsSection extends StatelessWidget {
  final List<DiscoveryCampaign> campaigns;

  const DiscoveryCampaignsSection({super.key, required this.campaigns});

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DiscoverySectionHeader(title: 'Active Campaigns'),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              for (var i = 0; i < campaigns.length; i++) ...[
                if (i > 0) SizedBox(height: 12.h),
                DiscoveryCampaignCard(
                  campaign: campaigns[i],
                  onTap: () =>
                      CampaignNavigation.openDetail(context, campaigns[i].id),
                  onDonateTap: () => CampaignNavigation.openDetail(
                    context,
                    campaigns[i].id,
                    donate: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
