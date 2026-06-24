import 'package:equatable/equatable.dart';

sealed class HomeSearchEvent extends Equatable {
  const HomeSearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchQueryChanged extends HomeSearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class SearchTabChanged extends HomeSearchEvent {
  final int tabIndex;
  const SearchTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

final class SearchCleared extends HomeSearchEvent {
  const SearchCleared();
}
