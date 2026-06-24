import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';

sealed class HomeSearchState extends Equatable {
  const HomeSearchState();

  @override
  List<Object?> get props => [];
}

final class HomeSearchInitial extends HomeSearchState {
  const HomeSearchInitial();
}

final class HomeSearchLoading extends HomeSearchState {
  const HomeSearchLoading();
}

final class HomeSearchLoaded extends HomeSearchState {
  final List<Post> posts;
  final List<ChurchEvent> events;
  final String query;
  final int activeTab; // 0: All, 1: Posts, 2: Events

  const HomeSearchLoaded({
    required this.posts,
    required this.events,
    required this.query,
    required this.activeTab,
  });

  HomeSearchLoaded copyWith({
    List<Post>? posts,
    List<ChurchEvent>? events,
    String? query,
    int? activeTab,
  }) {
    return HomeSearchLoaded(
      posts: posts ?? this.posts,
      events: events ?? this.events,
      query: query ?? this.query,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props => [posts, events, query, activeTab];
}

final class HomeSearchFailure extends HomeSearchState {
  final String message;
  const HomeSearchFailure(this.message);

  @override
  List<Object?> get props => [message];
}
