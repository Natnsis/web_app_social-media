class DonateCampaignDto {
  final double amountEtb;
  final String donorMessage;

  const DonateCampaignDto({
    required this.amountEtb,
    required this.donorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'amountEtb': amountEtb,
      'donorMessage': donorMessage,
    };
  }
}
