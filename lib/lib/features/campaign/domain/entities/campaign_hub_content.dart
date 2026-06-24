import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';

class CampaignHubContent extends Equatable {
  final CampaignHubFilter filter;
  final String searchQuery;
  final Campaign? featuredCampaign;
  final List<Campaign> campaigns;
  final List<Campaign> completedCampaigns;

  const CampaignHubContent({
    required this.filter,
    this.searchQuery = '',
    this.featuredCampaign,
    required this.campaigns,
    required this.completedCampaigns,
  });

  @override
  List<Object?> get props =>
      [filter, searchQuery, featuredCampaign, campaigns, completedCampaigns];
}
