import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';

sealed class NewCampaignEvent extends Equatable {
  const NewCampaignEvent();

  @override
  List<Object?> get props => [];
}

final class NewCampaignDraftUpdated extends NewCampaignEvent {
  final NewCampaignDraft draft;

  const NewCampaignDraftUpdated(this.draft);

  @override
  List<Object?> get props => [draft];
}

final class NewCampaignSubmitted extends NewCampaignEvent {
  const NewCampaignSubmitted();
}
