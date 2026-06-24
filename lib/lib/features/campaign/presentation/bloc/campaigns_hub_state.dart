import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_content.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';

sealed class CampaignsHubState extends Equatable {
  const CampaignsHubState();

  @override
  List<Object?> get props => [];
}

final class CampaignsHubInitial extends CampaignsHubState {
  const CampaignsHubInitial();
}

final class CampaignsHubLoading extends CampaignsHubState {
  final CampaignHubFilter filter;

  const CampaignsHubLoading({required this.filter});

  @override
  List<Object?> get props => [filter];
}

final class CampaignsHubLoaded extends CampaignsHubState {
  final CampaignHubContent content;

  const CampaignsHubLoaded(this.content);

  @override
  List<Object?> get props => [content];
}

final class CampaignsHubFailure extends CampaignsHubState {
  final String message;
  final CampaignHubFilter filter;

  const CampaignsHubFailure({
    required this.message,
    required this.filter,
  });

  @override
  List<Object?> get props => [message, filter];
}
