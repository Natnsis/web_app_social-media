import 'package:faithconnect/features/campaign/data/dto/campaign_api_dto.dart';

class CampaignDetailApiDto {
  final CampaignApiDto campaign;
  final int donorCount;
  final int contributionCount;

  const CampaignDetailApiDto({
    required this.campaign,
    this.donorCount = 0,
    this.contributionCount = 0,
  });

  factory CampaignDetailApiDto.fromJson(Map<String, dynamic> json) {
    final countMap = json['_count'];
    final counts = countMap is Map ? countMap : null;

    final explicitDonors = _intOrNull(json['donorCount']);
    final explicitContributions =
        _intOrNull(json['contributionCount'] ?? counts?['contributions']);

    return CampaignDetailApiDto(
      campaign: CampaignApiDto.fromJson(json),
      donorCount: explicitDonors ?? 0,
      contributionCount: explicitContributions ?? 0,
    );
  }

  static int? _intOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
