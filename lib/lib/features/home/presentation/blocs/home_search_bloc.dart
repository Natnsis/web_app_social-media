import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:faithconnect/features/post/data/datasources/posts_remote_datasource.dart';
import 'package:faithconnect/features/post/domain/entities/posts_query_filter.dart';
import 'package:faithconnect/features/event/application/event_service.dart';
import 'package:faithconnect/features/event/domain/entities/events_query_filter.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_search_event.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_search_state.dart';

class HomeSearchBloc extends Bloc<HomeSearchEvent, HomeSearchState> {
  final PostsRemoteDataSource _postsRemoteDataSource;
  final EventService _eventService;

  HomeSearchBloc({
    required PostsRemoteDataSource postsRemoteDataSource,
    required EventService eventService,
  })  : _postsRemoteDataSource = postsRemoteDataSource,
        _eventService = eventService,
        super(const HomeSearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: (events, mapper) {
        return events
            .debounceTime(const Duration(milliseconds: 350))
            .switchMap(mapper);
      },
    );
    on<SearchTabChanged>(_onTabChanged);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<HomeSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const HomeSearchInitial());
      return;
    }

    emit(const HomeSearchLoading());

    try {
      final postsFuture = _postsRemoteDataSource.fetchPosts(
        filter: PostsQueryFilter(search: query, limit: 20),
      );
      final eventsFuture = _eventService.fetchEvents(
        filter: EventsQueryFilter(search: query, limit: 20),
      );

      final results = await Future.wait([postsFuture, eventsFuture]);

      final postsResult = results[0] as PostsPageResult;
      final eventsResult = results[1] as Either<Failure, List<ChurchEvent>>;

      List<ChurchEvent> events = [];
      eventsResult.fold(
        (failure) {
          // propagate/handle silently
        },
        (fetchedEvents) {
          events = fetchedEvents;
        },
      );

      emit(HomeSearchLoaded(
        posts: postsResult.posts,
        events: events,
        query: query,
        activeTab: 0,
      ));
    } catch (e) {
      emit(HomeSearchFailure(e.toString()));
    }
  }

  void _onTabChanged(
    SearchTabChanged event,
    Emitter<HomeSearchState> emit,
  ) {
    final currentState = state;
    if (currentState is HomeSearchLoaded) {
      emit(currentState.copyWith(activeTab: event.tabIndex));
    }
  }

  void _onCleared(
    SearchCleared event,
    Emitter<HomeSearchState> emit,
  ) {
    emit(const HomeSearchInitial());
  }
}
