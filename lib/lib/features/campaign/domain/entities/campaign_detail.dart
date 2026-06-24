import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_donor.dart';

class CampaignDetail extends Equatable {
  final Campaign campaign;
  final String missionOverview;
  final int totalDonors;
  final int anonymousDonors;
  final double averageGiftEtb;
  final List<CampaignDonor> recentDonors;
  final bool allowAnonymousGiving;
  final bool showProgressPublicly;
  final String supportLabel;

  const CampaignDetail({
    required this.campaign,
    required this.missionOverview,
    required this.totalDonors,
    required this.anonymousDonors,
    required this.averageGiftEtb,
    required this.recentDonors,
    this.allowAnonymousGiving = true,
    this.showProgressPublicly = true,
    this.supportLabel = 'Active Support',
  });

  @override
  List<Object?> get props => [
        campaign,
        missionOverview,
        totalDonors,
        anonymousDonors,
        averageGiftEtb,
        recentDonors,
        allowAnonymousGiving,
        showProgressPublicly,
        supportLabel,
      ];
}
