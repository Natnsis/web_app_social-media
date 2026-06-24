import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_detail.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_donor.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_content.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_status.dart';

/// Local preview/fixture data for campaign UI development and tests.
abstract final class CampaignMockData {
  CampaignMockData._();

  static const String defaultCoverImage =
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800';

  static const _buildingImage = defaultCoverImage;
  static const _communityImage =
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800';
  static const _avatar =
      'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=200';

  static Campaign get featuredMedical => const Campaign(
        id: 'beza-medical-expansion',
        title: 'Beza Medical Center Expansion',
        description:
            'Providing accessible healthcare to over 50,000 residents through our state-of-the-art expansion.',
        imageUrl: _buildingImage,
        raisedAmountEtb: 4250000,
        goalAmountEtb: 8000000,
        status: CampaignStatus.active,
        isFeatured: true,
        organizationName: 'Beza International',
        location: 'Addis Ababa, Ethiopia',
        statusBadge: 'Ongoing Campaign',
        daysLeft: 42,
      );

  static List<Campaign> get _activeList => [
        featuredMedical,
        const Campaign(
          id: 'gojjam-water',
          title: 'Clean Water Initiative: Gojjam Region',
          description:
              'Bringing clean water access and pastoral care to remote communities.',
          imageUrl: _communityImage,
          raisedAmountEtb: 936000,
          goalAmountEtb: 1200000,
          status: CampaignStatus.active,
          tags: ['Rural Outreach', 'Education'],
          stewardshipTag: 'Stewardship',
          organizationName: 'Beza International',
          statusBadge: 'Active',
          daysLeft: 18,
        ),
        const Campaign(
          id: 'youth-discipleship',
          title: 'Youth Discipleship Center',
          description:
              'Building a safe space for mentorship, worship, and leadership training.',
          raisedAmountEtb: 310000,
          goalAmountEtb: 500000,
          status: CampaignStatus.active,
          tags: ['Youth'],
          organizationName: 'Beza International',
          statusBadge: 'Active',
          daysLeft: 30,
        ),
      ];

  static List<Campaign> get _completedList => [
        Campaign(
          id: 'food-bank-restock',
          title: 'Community Food Bank Re-stock',
          description: 'Completed food bank restock for local families in need.',
          imageUrl: _communityImage,
          raisedAmountEtb: 890000,
          goalAmountEtb: 850000,
          status: CampaignStatus.completed,
          organizationName: 'Beza International',
          statusBadge: 'SUCCESS',
          completedAt: DateTime(2023, 12, 1),
          beneficiaryCount: 1420,
          avatarUrl: _avatar,
        ),
      ];

  static CampaignHubContent hubContent(CampaignHubFilter filter) {
    final campaigns = switch (filter) {
      CampaignHubFilter.ourCampaigns => _activeList,
      CampaignHubFilter.following => _activeList.take(1).toList(),
    };

    return CampaignHubContent(
      filter: filter,
      searchQuery: '',
      featuredCampaign: featuredMedical,
      campaigns: campaigns,
      completedCampaigns: _completedList,
    );
  }

  static CampaignDetail detailFromCampaign(Campaign campaign) {
    return detail(campaign.id, campaignOverride: campaign);
  }

  static CampaignDetail detail(
    String id, {
    Campaign? campaignOverride,
  }) {
    final campaign = campaignOverride ??
        [..._activeList, ..._completedList].firstWhere(
          (c) => c.id == id,
          orElse: () => featuredMedical,
        );

    final now = DateTime.now();
    return CampaignDetail(
      campaign: campaign,
      missionOverview: campaign.description.isNotEmpty
          ? '${campaign.description}\n\nEvery gift is stewarded transparently with quarterly impact reports shared with our global partners.'
          : 'The Beza Medical Center Expansion project will add 12 new wards and a diagnostic wing to serve over 15,000 patients annually. Your support provides life-saving equipment, staff training, and compassionate care for families who otherwise could not afford treatment.\n\nEvery gift is stewarded transparently with quarterly impact reports shared with our global partners.',
      totalDonors: 143,
      anonymousDonors: 38,
      averageGiftEtb: 29720,
      recentDonors: [
        CampaignDonor(
          id: 'd1',
          displayName: 'Abebe T.',
          donatedAt: DateTime(2023, 10, 22),
          amountEtb: 10000,
        ),
        CampaignDonor(
          id: 'd2',
          displayName: 'Hanna M.',
          donatedAt: now.subtract(const Duration(days: 3)),
          amountEtb: 2500,
        ),
        CampaignDonor(
          id: 'd3',
          displayName: 'Anonymous',
          donatedAt: now.subtract(const Duration(days: 5)),
          amountEtb: 5000,
          isAnonymous: true,
        ),
      ],
    );
  }
}
