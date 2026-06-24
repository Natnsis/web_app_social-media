import 'package:equatable/equatable.dart';

class CampaignDonor extends Equatable {
  final String id;
  final String displayName;
  final DateTime donatedAt;
  final double amountEtb;
  final bool isAnonymous;

  const CampaignDonor({
    required this.id,
    required this.displayName,
    required this.donatedAt,
    required this.amountEtb,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props =>
      [id, displayName, donatedAt, amountEtb, isAnonymous];
}
