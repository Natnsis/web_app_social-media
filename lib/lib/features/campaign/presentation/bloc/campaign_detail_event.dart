import 'package:equatable/equatable.dart';

sealed class CampaignDetailEvent extends Equatable {
  const CampaignDetailEvent();

  @override
  List<Object?> get props => [];
}

final class CampaignDetailRequested extends CampaignDetailEvent {
  const CampaignDetailRequested();
}

final class CampaignDonateRequested extends CampaignDetailEvent {
  final double amountEtb;
  final String donorMessage;

  const CampaignDonateRequested({
    required this.amountEtb,
    required this.donorMessage,
  });

  @override
  List<Object?> get props => [amountEtb, donorMessage];
}

final class CampaignFeedbackDismissed extends CampaignDetailEvent {
  const CampaignFeedbackDismissed();
}

final class TransactionStatusChecked extends CampaignDetailEvent {
  final String txRef;

  const TransactionStatusChecked(this.txRef);

  @override
  List<Object?> get props => [txRef];
}
