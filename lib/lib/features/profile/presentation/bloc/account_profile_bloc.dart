import 'package:faithconnect/core/models/app_user_role.dart';
import 'package:faithconnect/core/models/user_entity.dart';

import 'package:faithconnect/core/services/shared_prefs_Service.dart';

import 'package:faithconnect/features/home/domain/entities/post.dart';

import 'package:faithconnect/features/profile/application/profile_service.dart';

import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart'
    show ProfileShortClip;

import 'package:faithconnect/features/profile/presentation/bloc/account_profile_event.dart';

import 'package:faithconnect/features/profile/presentation/bloc/account_profile_state.dart';

import 'package:faithconnect/features/user/application/user_service.dart';

import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class AccountProfileBloc extends Bloc<AccountProfileEvent, AccountProfileState> {

  final ProfileService _profileService;

  final UserService _userService;



  AccountProfileBloc({

    required ProfileService profileService,

    required UserService userService,

  })  : _profileService = profileService,

        _userService = userService,

        super(const AccountProfileInitial()) {

    on<AccountProfileRequested>(_onRequested);

    on<AccountProfileContentRequested>(_onContentRequested);

    on<AccountProfileUserRefreshRequested>(_onUserRefreshRequested);

    on<AccountProfilePostRemoved>(_onPostRemoved);

    on<AccountProfilePostUpdated>(_onPostUpdated);

    on<AccountProfileShortRemoved>(_onShortRemoved);

    on<AccountProfileShortUpdated>(_onShortUpdated);

    on<AccountProfileCampaignRemoved>(_onCampaignRemoved);

    on<AccountProfileCampaignUpdated>(_onCampaignUpdated);

    on<AccountProfileEventRemoved>(_onEventRemoved);

    on<AccountProfileEventUpdated>(_onEventUpdated);

  }



  Future<User?> _fetchCurrentUser() async {

    final result = await _userService.getCurrentUserProfile();

    return result.fold(

      (_) async => SharedPrefsService.getUser(),

      (user) => user,

    );

  }

  Future<void> _syncShellRoles(User? user) async {
    if (user == null || user.roles.isEmpty) return;
    if (!sl.isRegistered<HomeShellModeNotifier>()) return;
    await sl<HomeShellModeNotifier>().applyUserRoles(user.roles);
    await SharedPrefsService.saveUser(user);
  }

  bool _resolveChurchMode(bool requested, User? user) {
    if (UserRoleCapabilities.canManageChurchContent(user?.roles ?? const [])) {
      return true;
    }
    return requested;
  }



  Future<void> _onRequested(

    AccountProfileRequested event,

    Emitter<AccountProfileState> emit,

  ) async {

    emit(const AccountProfileLoading());



    final currentUser = await _fetchCurrentUser();
    await _syncShellRoles(currentUser);

    final result = await _profileService.getOrganizationProfile();

    await result.fold(

      (failure) async => emit(AccountProfileFailure(failure.message)),

      (profile) async {

        emit(

          AccountProfileLoaded(

            profile: profile,

            currentUser: currentUser,

            isContentLoading: true,

          ),

        );

        await _loadContent(
          emit,
          churchMode: _resolveChurchMode(event.churchMode, currentUser),
        );

      },

    );

  }



  Future<void> _onContentRequested(

    AccountProfileContentRequested event,

    Emitter<AccountProfileState> emit,

  ) async {

    final current = state;

    if (current is! AccountProfileLoaded) return;



    final currentUser = await _fetchCurrentUser();
    await _syncShellRoles(currentUser);

    emit(

      current.copyWith(

        currentUser: currentUser,

        isContentLoading: true,

        clearContentError: true,

      ),

    );



    await _loadContent(
      emit,
      churchMode: _resolveChurchMode(event.churchMode, currentUser),
    );

  }



  Future<void> _onUserRefreshRequested(

    AccountProfileUserRefreshRequested event,

    Emitter<AccountProfileState> emit,

  ) async {

    final current = state;

    if (current is! AccountProfileLoaded) return;



    final currentUser = await _fetchCurrentUser();
    await _syncShellRoles(currentUser);

    emit(current.copyWith(currentUser: currentUser));

  }



  Future<void> _loadContent(

    Emitter<AccountProfileState> emit, {

    required bool churchMode,

  }) async {

    final current = state;

    if (current is! AccountProfileLoaded) return;



    final result = await _profileService.getAccountProfileContent(

      churchMode: churchMode,

    );



    result.fold(

      (failure) => emit(

        current.copyWith(

          isContentLoading: false,

          contentError: failure.message,

        ),

      ),

      (content) => emit(

        current.copyWith(

          content: content,

          isContentLoading: false,

          clearContentError: true,

        ),

      ),

    );

  }



  void _onPostRemoved(

    AccountProfilePostRemoved event,

    Emitter<AccountProfileState> emit,

  ) {

    final current = state;

    if (current is! AccountProfileLoaded || current.content == null) return;



    emit(

      current.copyWith(

        content: current.content!.withoutPost(event.postId),

      ),

    );

  }



  void _onPostUpdated(

    AccountProfilePostUpdated event,

    Emitter<AccountProfileState> emit,

  ) {

    final current = state;

    if (current is! AccountProfileLoaded || current.content == null) return;



    final content = current.content!;

    Post? updatedPost;

    for (final post in [...content.posts, ...content.videos]) {

      if (post.id == event.postId) {

        updatedPost = post.copyWith(content: event.content);

        break;

      }

    }

    if (updatedPost == null) return;



    emit(

      current.copyWith(

        content: content.withUpdatedPost(updatedPost),

      ),

    );

  }



  void _onShortRemoved(

    AccountProfileShortRemoved event,

    Emitter<AccountProfileState> emit,

  ) {

    final current = state;

    if (current is! AccountProfileLoaded || current.content == null) return;



    emit(

      current.copyWith(

        content: current.content!.withoutShort(event.shortId),

      ),

    );

  }



  void _onShortUpdated(

    AccountProfileShortUpdated event,

    Emitter<AccountProfileState> emit,

  ) {

    final current = state;

    if (current is! AccountProfileLoaded || current.content == null) return;



    final content = current.content!;

    ProfileShortClip? updatedShort;

    for (final short in content.shorts) {

      if (short.id == event.shortId) {

        updatedShort = short.copyWith(title: event.title);

        break;

      }

    }

    if (updatedShort == null) return;



    emit(
      current.copyWith(
        content: content.withUpdatedShort(updatedShort),
      ),
    );
  }

  void _onCampaignRemoved(
    AccountProfileCampaignRemoved event,
    Emitter<AccountProfileState> emit,
  ) {
    final current = state;
    if (current is! AccountProfileLoaded || current.content == null) return;

    emit(
      current.copyWith(
        content: current.content!.withoutCampaign(event.campaignId),
      ),
    );
  }

  void _onCampaignUpdated(
    AccountProfileCampaignUpdated event,
    Emitter<AccountProfileState> emit,
  ) {
    final current = state;
    if (current is! AccountProfileLoaded || current.content == null) return;

    emit(
      current.copyWith(
        content: current.content!.withUpdatedCampaign(
          event.campaignId,
          event.title,
        ),
      ),
    );
  }

  void _onEventRemoved(
    AccountProfileEventRemoved event,
    Emitter<AccountProfileState> emit,
  ) {
    final current = state;
    if (current is! AccountProfileLoaded || current.content == null) return;

    emit(
      current.copyWith(
        content: current.content!.withoutEvent(event.eventId),
      ),
    );
  }

  void _onEventUpdated(
    AccountProfileEventUpdated event,
    Emitter<AccountProfileState> emit,
  ) {
    final current = state;
    if (current is! AccountProfileLoaded || current.content == null) return;

    emit(
      current.copyWith(
        content: current.content!.withUpdatedEvent(
          event.eventId,
          event.title,
        ),
      ),
    );
  }
}


