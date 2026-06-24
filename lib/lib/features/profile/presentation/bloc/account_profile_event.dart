import 'package:equatable/equatable.dart';

sealed class AccountProfileEvent extends Equatable {
  const AccountProfileEvent();

  @override
  List<Object?> get props => [];
}

final class AccountProfileRequested extends AccountProfileEvent {
  final bool churchMode;

  const AccountProfileRequested({this.churchMode = true});

  @override
  List<Object?> get props => [churchMode];
}

final class AccountProfileContentRequested extends AccountProfileEvent {
  final bool churchMode;

  const AccountProfileContentRequested({required this.churchMode});

  @override
  List<Object?> get props => [churchMode];
}

/// Refreshes `GET /v1/users/me` after edit profile or similar.
final class AccountProfileUserRefreshRequested extends AccountProfileEvent {
  const AccountProfileUserRefreshRequested();
}

final class AccountProfilePostRemoved extends AccountProfileEvent {
  final String postId;

  const AccountProfilePostRemoved(this.postId);

  @override
  List<Object?> get props => [postId];
}

final class AccountProfilePostUpdated extends AccountProfileEvent {
  final String postId;
  final String content;

  const AccountProfilePostUpdated({
    required this.postId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, content];
}

final class AccountProfileShortRemoved extends AccountProfileEvent {
  final String shortId;

  const AccountProfileShortRemoved(this.shortId);

  @override
  List<Object?> get props => [shortId];
}

final class AccountProfileShortUpdated extends AccountProfileEvent {
  final String shortId;
  final String title;

  const AccountProfileShortUpdated({
    required this.shortId,
    required this.title,
  });

  @override
  List<Object?> get props => [shortId, title];
}

final class AccountProfileCampaignRemoved extends AccountProfileEvent {
  final String campaignId;

  const AccountProfileCampaignRemoved(this.campaignId);

  @override
  List<Object?> get props => [campaignId];
}

final class AccountProfileCampaignUpdated extends AccountProfileEvent {
  final String campaignId;
  final String title;

  const AccountProfileCampaignUpdated({
    required this.campaignId,
    required this.title,
  });

  @override
  List<Object?> get props => [campaignId, title];
}

final class AccountProfileEventRemoved extends AccountProfileEvent {
  final String eventId;

  const AccountProfileEventRemoved(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

final class AccountProfileEventUpdated extends AccountProfileEvent {
  final String eventId;
  final String title;

  const AccountProfileEventUpdated({
    required this.eventId,
    required this.title,
  });

  @override
  List<Object?> get props => [eventId, title];
}
