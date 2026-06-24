enum CampaignHubFilter {
  ourCampaigns,
  following,
}

extension CampaignHubFilterX on CampaignHubFilter {
  String get label => switch (this) {
        CampaignHubFilter.ourCampaigns => 'Our Campaigns',
        CampaignHubFilter.following => 'Following',
      };
}
