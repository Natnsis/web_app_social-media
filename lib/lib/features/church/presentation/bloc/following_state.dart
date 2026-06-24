import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/church/domain/entities/following_analytics_summary.dart';
import 'package:faithconnect/features/church/domain/entities/following_church.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';

sealed class FollowingState extends Equatable {
  const FollowingState();

  @override
  List<Object?> get props => [];
}

final class FollowingInitial extends FollowingState {
  const FollowingInitial();
}

final class FollowingLoading extends FollowingState {
  final GiftPeriod period;

  const FollowingLoading({this.period = GiftPeriod.month});

  @override
  List<Object?> get props => [period];
}

final class FollowingLoaded extends FollowingState {
  final List<FollowingChurch> churches;
  final ApiListMeta meta;
  final FollowingAnalyticsSummary analytics;
  final bool isLoadingMore;
  final String? errorMessage;

  const FollowingLoaded({
    required this.churches,
    required this.meta,
    required this.analytics,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  FollowingLoaded copyWith({
    List<FollowingChurch>? churches,
    ApiListMeta? meta,
    FollowingAnalyticsSummary? analytics,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return FollowingLoaded(
      churches: churches ?? this.churches,
      meta: meta ?? this.meta,
      analytics: analytics ?? this.analytics,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [churches, meta, analytics, isLoadingMore, errorMessage];
}

final class FollowingFailure extends FollowingState {
  final String message;

  const FollowingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
