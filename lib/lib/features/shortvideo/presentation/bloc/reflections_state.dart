import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflections_feed.dart';

sealed class ReflectionsState extends Equatable {
  const ReflectionsState();

  @override
  List<Object?> get props => [];
}

final class ReflectionsInitial extends ReflectionsState {
  const ReflectionsInitial();
}

final class ReflectionsLoading extends ReflectionsState {
  const ReflectionsLoading();
}

final class ReflectionsLoaded extends ReflectionsState {
  final ReflectionsFeed feed;
  final bool isSubmitting;
  final Set<String> loadingReplyParentIds;
  final String? feedbackMessage;

  const ReflectionsLoaded({
    required this.feed,
    this.isSubmitting = false,
    this.loadingReplyParentIds = const {},
    this.feedbackMessage,
  });

  ReflectionsLoaded copyWith({
    ReflectionsFeed? feed,
    bool? isSubmitting,
    Set<String>? loadingReplyParentIds,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return ReflectionsLoaded(
      feed: feed ?? this.feed,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      loadingReplyParentIds:
          loadingReplyParentIds ?? this.loadingReplyParentIds,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  @override
  List<Object?> get props =>
      [feed, isSubmitting, loadingReplyParentIds, feedbackMessage];
}

final class ReflectionsFailure extends ReflectionsState {
  final String message;

  const ReflectionsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
