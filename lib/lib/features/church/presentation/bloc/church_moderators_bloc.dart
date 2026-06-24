import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_event.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_state.dart';
import 'package:faithconnect/features/user/application/user_service.dart';

class ChurchModeratorsBloc
    extends Bloc<ChurchModeratorsEvent, ChurchModeratorsState> {
  final ChurchService _churchService;
  final UserService _userService;
  int _searchGeneration = 0;

  ChurchModeratorsBloc({
    required ChurchService churchService,
    required UserService userService,
  })  : _churchService = churchService,
        _userService = userService,
        super(const ChurchModeratorsInitial()) {
    on<ChurchModeratorsRequested>(_onRequested);
    on<ChurchModeratorAssignSubmitted>(_onAssignSubmitted);
    on<ChurchModeratorRevokeSubmitted>(_onRevokeSubmitted);
    on<ChurchModeratorUserSearchRequested>(_onUserSearchRequested);

    add(const ChurchModeratorsRequested());
  }

  Future<void> _onRequested(
    ChurchModeratorsRequested event,
    Emitter<ChurchModeratorsState> emit,
  ) async {
    emit(const ChurchModeratorsLoading());

    final result = await _churchService.getMyChurchMembers();
    result.fold(
      (failure) => emit(ChurchModeratorsFailure(failure.message)),
      (members) => emit(ChurchModeratorsLoaded(members: members)),
    );
  }

  Future<void> _onUserSearchRequested(
    ChurchModeratorUserSearchRequested event,
    Emitter<ChurchModeratorsState> emit,
  ) async {
    final current = state;
    if (current is! ChurchModeratorsLoaded) return;

    final query = event.query.trim();
    final generation = ++_searchGeneration;

    emit(
      current.copyWith(
        searchQuery: query,
        isSearchingUsers: true,
        clearSearchErrorMessage: true,
        searchResults: query.isEmpty ? const [] : current.searchResults,
      ),
    );

    if (query.isEmpty) {
      emit(
        (state as ChurchModeratorsLoaded).copyWith(
          isSearchingUsers: false,
          searchResults: const [],
        ),
      );
      return;
    }

    final result = await _userService.searchUsers(query: query);

    if (generation != _searchGeneration) return;

    final latest = state;
    if (latest is! ChurchModeratorsLoaded) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isSearchingUsers: false,
          searchErrorMessage: failure.message,
          searchResults: const [],
        ),
      ),
      (users) {
        final existingIds = latest.members.map((m) => m.userId).toSet();
        emit(
          latest.copyWith(
            isSearchingUsers: false,
            searchResults:
                users.where((user) => !existingIds.contains(user.id)).toList(),
          ),
        );
      },
    );
  }

  Future<void> _onAssignSubmitted(
    ChurchModeratorAssignSubmitted event,
    Emitter<ChurchModeratorsState> emit,
  ) async {
    final current = state;
    if (current is! ChurchModeratorsLoaded) return;

    emit(current.copyWith(isAssigning: true, clearErrorMessage: true));

    final result = await _churchService.assignModerator(userId: event.userId);

    result.fold(
      (failure) => emit(
        current.copyWith(
          isAssigning: false,
          errorMessage: failure.message,
        ),
      ),
      (member) {
        final exists = current.members.any((m) => m.userId == member.userId);
        final updatedMembers =
            exists ? current.members : [member, ...current.members];
        final existingIds = updatedMembers.map((m) => m.userId).toSet();

        emit(
          ChurchModeratorsLoaded(
            members: updatedMembers,
            searchQuery: current.searchQuery,
            searchResults: current.searchResults
                .where((user) => !existingIds.contains(user.id))
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> _onRevokeSubmitted(
    ChurchModeratorRevokeSubmitted event,
    Emitter<ChurchModeratorsState> emit,
  ) async {
    final current = state;
    if (current is! ChurchModeratorsLoaded) return;

    emit(current.copyWith(isAssigning: true, clearErrorMessage: true));

    final result = await _churchService.revokeModerator(userId: event.userId);

    result.fold(
      (failure) => emit(
        current.copyWith(
          isAssigning: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          ChurchModeratorsLoaded(
            members:
                current.members.where((m) => m.userId != event.userId).toList(),
            searchQuery: current.searchQuery,
            searchResults: current.searchResults,
          ),
        );
      },
    );
  }
}
