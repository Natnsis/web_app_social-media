import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:faithconnect/features/church/application/church_service.dart';

import 'package:faithconnect/features/church/domain/entities/church_profile_tab.dart';

import 'package:faithconnect/features/church/presentation/bloc/church_event.dart';

import 'package:faithconnect/features/church/presentation/bloc/church_state.dart';



class ChurchBloc extends Bloc<ChurchEvent, ChurchState> {

  final ChurchService _churchService;



  ChurchBloc({

    required ChurchService churchService,

    String? profileId,

  })  : _churchService = churchService,

        super(ChurchLoading(profileId ?? '')) {

    on<ChurchProfileRequested>(_onProfileRequested);

    on<ChurchProfileRefreshed>(_onProfileRefreshed);

    on<ChurchProfileTabChanged>(_onProfileTabChanged);

    on<ChurchProfileFollowToggled>(_onFollowToggled);

    on<ChurchProfileUnfollowRequested>(_onUnfollowRequested);

    on<ChurchFollowActionCleared>(_onFollowActionCleared);



    if (profileId != null && profileId.isNotEmpty) {

      add(ChurchProfileRequested(profileId));

    }

  }



  Future<void> _onProfileRequested(

    ChurchProfileRequested event,

    Emitter<ChurchState> emit,

  ) async {

    await _loadProfile(

      event.profileId,

      emit,

      ChurchProfileTab.members,

      showFullScreenLoading: true,

    );

  }



  Future<void> _onProfileRefreshed(

    ChurchProfileRefreshed event,

    Emitter<ChurchState> emit,

  ) async {

    final current = state;

    final tab = current is ChurchProfileLoaded

        ? current.selectedTab

        : ChurchProfileTab.members;



    if (current is ChurchProfileLoaded &&

        current.requestedProfileId == event.profileId) {

      emit(current.copyWith(isRefreshing: true));

    }



    await _loadProfile(

      event.profileId,

      emit,

      tab,

      showFullScreenLoading: false,

    );

  }



  Future<void> _loadProfile(

    String profileId,

    Emitter<ChurchState> emit,

    ChurchProfileTab tab, {

    required bool showFullScreenLoading,

  }) async {

    if (profileId.isEmpty) {

      emit(const ChurchFailure('Invalid profile', profileId: ''));

      return;

    }



    if (showFullScreenLoading) {

      emit(ChurchLoading(profileId));

    }



    final result = await _churchService.getChurchProfile(profileId);

    result.fold(

      (failure) => emit(

        ChurchFailure(failure.message, profileId: profileId),

      ),

      (feed) => emit(

        ChurchProfileLoaded(

          profileFeed: feed,

          requestedProfileId: profileId,

          selectedTab: tab,

          isRefreshing: false,

        ),

      ),

    );

  }



  void _onProfileTabChanged(

    ChurchProfileTabChanged event,

    Emitter<ChurchState> emit,

  ) {

    final current = state;

    if (current is ChurchProfileLoaded) {

      emit(current.copyWith(selectedTab: event.tab));

    }

  }



  Future<void> _onFollowToggled(

    ChurchProfileFollowToggled event,

    Emitter<ChurchState> emit,

  ) async {

    final current = state;

    if (current is! ChurchProfileLoaded) return;



    final profile = current.profileFeed.profile;

    if (profile.isFollowing) return;



    final previous = current;

    emit(

      current.copyWith(

        clearFollowActionError: true,

        profileFeed: current.profileFeed.copyWith(

          profile: profile.copyWith(isFollowing: true),

        ),

      ),

    );



    final result = await _churchService.toggleFollowChurch(

      churchId: profile.id,

      follow: true,

    );



    result.fold(

      (failure) => emit(

        previous.copyWith(followActionError: failure.message),

      ),

      (_) {},

    );

  }



  Future<void> _onUnfollowRequested(

    ChurchProfileUnfollowRequested event,

    Emitter<ChurchState> emit,

  ) async {

    final current = state;

    if (current is! ChurchProfileLoaded) return;



    final profile = current.profileFeed.profile;

    if (!profile.isFollowing) return;



    final previous = current;

    emit(

      current.copyWith(

        clearFollowActionError: true,

        profileFeed: current.profileFeed.copyWith(

          profile: profile.copyWith(isFollowing: false),

        ),

      ),

    );



    final result = await _churchService.unfollowChurch(churchId: profile.id);



    result.fold(

      (failure) => emit(

        previous.copyWith(followActionError: failure.message),

      ),

      (_) {},

    );

  }



  void _onFollowActionCleared(

    ChurchFollowActionCleared event,

    Emitter<ChurchState> emit,

  ) {

    final current = state;

    if (current is ChurchProfileLoaded) {

      emit(current.copyWith(clearFollowActionError: true));

    }

  }

}


