import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:faithconnect/features/user/domain/entities/searched_user.dart';

sealed class ChurchModeratorsState extends Equatable {
  const ChurchModeratorsState();

  @override
  List<Object?> get props => [];
}

final class ChurchModeratorsInitial extends ChurchModeratorsState {
  const ChurchModeratorsInitial();
}

final class ChurchModeratorsLoading extends ChurchModeratorsState {
  const ChurchModeratorsLoading();
}

final class ChurchModeratorsLoaded extends ChurchModeratorsState {
  final List<ChurchMember> members;
  final bool isAssigning;
  final String? errorMessage;
  final String searchQuery;
  final List<SearchedUser> searchResults;
  final bool isSearchingUsers;
  final String? searchErrorMessage;

  const ChurchModeratorsLoaded({
    required this.members,
    this.isAssigning = false,
    this.errorMessage,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearchingUsers = false,
    this.searchErrorMessage,
  });

  ChurchModeratorsLoaded copyWith({
    List<ChurchMember>? members,
    bool? isAssigning,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? searchQuery,
    List<SearchedUser>? searchResults,
    bool? isSearchingUsers,
    String? searchErrorMessage,
    bool clearSearchErrorMessage = false,
  }) {
    return ChurchModeratorsLoaded(
      members: members ?? this.members,
      isAssigning: isAssigning ?? this.isAssigning,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearchingUsers: isSearchingUsers ?? this.isSearchingUsers,
      searchErrorMessage: clearSearchErrorMessage
          ? null
          : (searchErrorMessage ?? this.searchErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        members,
        isAssigning,
        errorMessage,
        searchQuery,
        searchResults,
        isSearchingUsers,
        searchErrorMessage,
      ];
}

final class ChurchModeratorsFailure extends ChurchModeratorsState {
  final String message;

  const ChurchModeratorsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
