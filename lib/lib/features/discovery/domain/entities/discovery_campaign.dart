import 'package:equatable/equatable.dart';

class DiscoveryCampaign extends Equatable {
  final String id;
  final String title;
  final String organizationName;
  final double raisedAmountEtb;
  final double goalAmountEtb;
  final int daysLeft;
  final String? imageUrl;

  const DiscoveryCampaign({
    required this.id,
    required this.title,
    required this.organizationName,
    required this.raisedAmountEtb,
    required this.goalAmountEtb,
    required this.daysLeft,
    this.imageUrl,
  });

  double get progress =>
      goalAmountEtb <= 0 ? 0 : (raisedAmountEtb / goalAmountEtb).clamp(0, 1);

  int get progressPercentRounded => (progress * 100).round();

  @override
  List<Object?> get props =>
      [id, title, organizationName, raisedAmountEtb, goalAmountEtb, daysLeft, imageUrl];
}
