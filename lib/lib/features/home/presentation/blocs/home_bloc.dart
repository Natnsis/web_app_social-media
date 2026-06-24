import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/home/application/home_service.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_event.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService _homeService;

  HomeBloc({required HomeService homeService})
      : _homeService = homeService,
        super(const HomeInitial()) {
    on<HomeFeedRequested>(_onFeedRequested);
    on<HomeFeedRefreshed>(_onFeedRefreshed);
    on<HomeFeedBackgroundRefreshed>(_onBackgroundRefreshed);
    on<HomeFeedApplyUpdates>(_onApplyUpdates);
  }

  Future<void> _onFeedRequested(
    HomeFeedRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadFeed(emit);
  }

  Future<void> _onFeedRefreshed(
    HomeFeedRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) {
      emit(const HomeLoading());
    }
    final result = await _homeService.getFeed();
    result.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (feed) => emit(HomeLoaded(feed)),
    );
  }

  Future<void> _onBackgroundRefreshed(
    HomeFeedBackgroundRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final result = await _homeService.getFeed();
    result.fold(
      (failure) {
        // Ignore background failures silently
      },
      (newFeed) {
        // Compare feed posts to determine if there's new content
        final currentTopPostId = currentState.feed.posts.isNotEmpty 
            ? currentState.feed.posts.first.id 
            : null;
        final newTopPostId = newFeed.posts.isNotEmpty 
            ? newFeed.posts.first.id 
            : null;

        if (currentTopPostId != newTopPostId || currentState.feed.posts.length != newFeed.posts.length) {
          emit(currentState.copyWith(
            pendingFeed: newFeed,
            hasUpdatesAvailable: true,
          ));
        }
      },
    );
  }

  void _onApplyUpdates(
    HomeFeedApplyUpdates event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is HomeLoaded && currentState.pendingFeed != null) {
      emit(HomeLoaded(currentState.pendingFeed!));
    }
  }

  Future<void> _loadFeed(Emitter<HomeState> emit) async {
    final result = await _homeService.getFeed();
    result.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (feed) => emit(HomeLoaded(feed)),
    );
  }
}
