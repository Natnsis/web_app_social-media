import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_tab.dart';

sealed class ChurchState extends Equatable {
  const ChurchState();

  @override
  List<Object?> get props => [];
}

final class ChurchInitial extends ChurchState {
  const ChurchInitial();
}

final class ChurchLoading extends ChurchState {
  final String profileId;

  const ChurchLoading(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

final class ChurchProfileLoaded extends ChurchState {
  final ChurchProfileFeed profileFeed;
  final String requestedProfileId;
  final ChurchProfileTab selectedTab;
  final bool isRefreshing;
  final String? followActionError;

  const ChurchProfileLoaded({
    required this.profileFeed,
    required this.requestedProfileId,
    this.selectedTab = ChurchProfileTab.members,
    this.isRefreshing = false,
    this.followActionError,
  });

  ChurchProfileLoaded copyWith({
    ChurchProfileFeed? profileFeed,
    String? requestedProfileId,
    ChurchProfileTab? selectedTab,
    bool? isRefreshing,
    String? followActionError,
    bool clearFollowActionError = false,
  }) {
    return ChurchProfileLoaded(
      profileFeed: profileFeed ?? this.profileFeed,
      requestedProfileId: requestedProfileId ?? this.requestedProfileId,
      selectedTab: selectedTab ?? this.selectedTab,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      followActionError: clearFollowActionError
          ? null
          : (followActionError ?? this.followActionError),
    );
  }

  @override
  List<Object?> get props => [
        profileFeed,
        requestedProfileId,
        selectedTab,
        isRefreshing,
        followActionError,
      ];
}

final class ChurchFailure extends ChurchState {
  final String message;
  final String profileId;

  const ChurchFailure(this.message, {required this.profileId});

  @override
  List<Object?> get props => [message, profileId];
}
