import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/features/profile/domain/entities/account_profile_content.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';

sealed class AccountProfileState extends Equatable {
  const AccountProfileState();

  @override
  List<Object?> get props => [];
}

final class AccountProfileInitial extends AccountProfileState {
  const AccountProfileInitial();
}

final class AccountProfileLoading extends AccountProfileState {
  const AccountProfileLoading();
}

final class AccountProfileLoaded extends AccountProfileState {
  final OrganizationProfile profile;
  final User? currentUser;
  final AccountProfileContent? content;
  final bool isContentLoading;
  final String? contentError;

  const AccountProfileLoaded({
    required this.profile,
    this.currentUser,
    this.content,
    this.isContentLoading = false,
    this.contentError,
  });

  AccountProfileLoaded copyWith({
    OrganizationProfile? profile,
    User? currentUser,
    AccountProfileContent? content,
    bool? isContentLoading,
    String? contentError,
    bool clearContentError = false,
  }) {
    return AccountProfileLoaded(
      profile: profile ?? this.profile,
      currentUser: currentUser ?? this.currentUser,
      content: content ?? this.content,
      isContentLoading: isContentLoading ?? this.isContentLoading,
      contentError:
          clearContentError ? null : (contentError ?? this.contentError),
    );
  }

  @override
  List<Object?> get props =>
      [profile, currentUser, content, isContentLoading, contentError];
}

final class AccountProfileFailure extends AccountProfileState {
  final String message;

  const AccountProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
