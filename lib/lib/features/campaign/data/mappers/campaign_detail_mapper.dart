import 'package:faithconnect/features/campaign/data/dto/campaign_detail_api_dto.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_detail.dart';

abstract final class CampaignDetailMapper {
  CampaignDetailMapper._();

  static CampaignDetail fromDto(CampaignDetailApiDto dto) {
    final campaign = dto.campaign.toCampaign();
    final totalDonors = dto.donorCount;
    final avgGift = totalDonors > 0 ? campaign.raisedAmountEtb / totalDonors : 0.0;

    return CampaignDetail(
      campaign: campaign,
      missionOverview: campaign.description.isNotEmpty
          ? campaign.description
          : 'Community fundraising campaign',
      totalDonors: totalDonors,
      anonymousDonors: 0,
      averageGiftEtb: avgGift,
      recentDonors: const [],
    );
  }
}
