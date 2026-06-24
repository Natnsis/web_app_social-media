import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';

sealed class CampaignsHubEvent extends Equatable {
  const CampaignsHubEvent();

  @override
  List<Object?> get props => [];
}

final class CampaignsHubRequested extends CampaignsHubEvent {
  const CampaignsHubRequested();
}

final class CampaignsHubFilterChanged extends CampaignsHubEvent {
  final CampaignHubFilter filter;

  const CampaignsHubFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Reload hub content without clearing the current list (smooth return from create).
final class CampaignsHubRefreshed extends CampaignsHubEvent {
  const CampaignsHubRefreshed();
}

final class CampaignsHubSearchChanged extends CampaignsHubEvent {
  final String query;

  const CampaignsHubSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
