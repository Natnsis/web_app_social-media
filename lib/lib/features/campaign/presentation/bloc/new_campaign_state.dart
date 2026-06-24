import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';

sealed class NewCampaignState extends Equatable {
  const NewCampaignState();

  @override
  List<Object?> get props => [];
}

final class NewCampaignEditing extends NewCampaignState {
  final NewCampaignDraft draft;

  const NewCampaignEditing(this.draft);

  @override
  List<Object?> get props => [draft];
}

final class NewCampaignSuccess extends NewCampaignState {
  final String campaignId;

  const NewCampaignSuccess(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

final class NewCampaignFailure extends NewCampaignState {
  final NewCampaignDraft draft;
  final String message;

  const NewCampaignFailure({
    required this.draft,
    required this.message,
  });

  @override
  List<Object?> get props => [draft, message];
}
