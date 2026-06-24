import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/church/domain/entities/following_analytics_summary.dart';
import 'package:faithconnect/features/church/domain/entities/following_church.dart';
import 'package:faithconnect/features/church/presentation/bloc/following_event.dart';
import 'package:faithconnect/features/church/presentation/bloc/following_state.dart';
import 'package:faithconnect/features/profile/application/profile_service.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';

class FollowingBloc extends Bloc<FollowingEvent, FollowingState> {
  final ChurchService _churchService;
  final ProfileService _profileService;

  FollowingBloc({
    required ChurchService churchService,
    required ProfileService profileService,
  })  : _churchService = churchService,
        _profileService = profileService,
        super(const FollowingInitial()) {
    on<FollowingRequested>(_onRequested);
    on<FollowingPeriodChanged>(_onPeriodChanged);
    on<FollowingLoadMore>(_onLoadMore);
    on<FollowingUnfollowToggled>(_onUnfollowToggled);

    add(const FollowingRequested());
  }

  Future<void> _onRequested(
    FollowingRequested event,
    Emitter<FollowingState> emit,
  ) async {
    await _load(GiftPeriod.month, emit);
  }

  Future<void> _onPeriodChanged(
    FollowingPeriodChanged event,
    Emitter<FollowingState> emit,
  ) async {
    await _load(event.period, emit, keepChurches: true);
  }

  Future<void> _load(
    GiftPeriod period,
    Emitter<FollowingState> emit, {
    bool keepChurches = false,
  }) async {
    final current = state;
    final existingChurches =
        keepChurches && current is FollowingLoaded ? current.churches : null;
    final existingMeta =
        keepChurches && current is FollowingLoaded ? current.meta : null;

    emit(FollowingLoading(period: period));

    final churchesResult = existingChurches != null && existingMeta != null
        ? null
        : await _churchService.getFollowingChurches();
    final analyticsResult = await _profileService.getSubscribersSummary(period);

    if (churchesResult != null) {
      final churchesFold = churchesResult;
      return churchesFold.fold(
        (failure) => emit(FollowingFailure(failure.message)),
        (page) => _emitLoaded(
          emit,
          churches: page.churches,
          meta: page.meta,
          analyticsResult: analyticsResult,
          period: period,
        ),
      );
    }

    if (existingChurches == null || existingMeta == null) {
      emit(const FollowingFailure('Unable to load following churches.'));
      return;
    }

    _emitLoaded(
      emit,
      churches: existingChurches,
      meta: existingMeta,
      analyticsResult: analyticsResult,
      period: period,
    );
  }

  void _emitLoaded(
    Emitter<FollowingState> emit, {
    required List<FollowingChurch> churches,
    required ApiListMeta meta,
    required dynamic analyticsResult,
    required GiftPeriod period,
  }) {
    analyticsResult.fold(
      (failure) => emit(FollowingFailure(failure.message)),
      (summary) => emit(
        FollowingLoaded(
          churches: churches,
          meta: meta,
          analytics: _toAnalyticsSummary(
            summary: summary as SubscribersSummary,
            totalFollowing: meta.total,
          ),
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    FollowingLoadMore event,
    Emitter<FollowingState> emit,
  ) async {
    final current = state;
    if (current is! FollowingLoaded ||
        current.isLoadingMore ||
        !current.meta.hasNextPage) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final result = await _churchService.getFollowingChurches(
      page: current.meta.page + 1,
      limit: current.meta.limit,
    );

    result.fold(
      (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        current.copyWith(
          churches: [...current.churches, ...page.churches],
          meta: page.meta,
          isLoadingMore: false,
          analytics: current.analytics.copyWith(
            totalFollowing: page.meta.total,
            previousPeriodTotal: _previousPeriodTotal(
              page.meta.total,
              current.analytics.growthPercent,
            ),
            trendPoints: _scaleTrendPoints(
              current.analytics.trendPoints,
              page.meta.total,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onUnfollowToggled(
    FollowingUnfollowToggled event,
    Emitter<FollowingState> emit,
  ) async {
    final current = state;
    if (current is! FollowingLoaded) return;

    final previous = current;
    final updatedTotal = (previous.meta.total - 1).clamp(0, 999999999);
    final updatedChurches = previous.churches
        .where((church) => church.id != event.churchId)
        .toList();
    final updatedMeta = ApiListMeta(
      page: previous.meta.page,
      limit: previous.meta.limit,
      total: updatedTotal,
      totalPages: previous.meta.totalPages,
      hasNextPage: previous.meta.hasNextPage,
      hasPreviousPage: previous.meta.hasPreviousPage,
    );
    final updatedAnalytics = FollowingAnalyticsSummary(
      period: previous.analytics.period,
      totalFollowing: updatedTotal,
      previousPeriodTotal: _previousPeriodTotal(
        updatedTotal,
        previous.analytics.growthPercent,
      ),
      growthPercent: previous.analytics.growthPercent,
      periodRangeLabel: previous.analytics.periodRangeLabel,
      trendPoints: _scaleTrendPoints(
        previous.analytics.trendPoints,
        updatedTotal,
      ),
    );

    emit(
      previous.copyWith(
        churches: updatedChurches,
        meta: updatedMeta,
        analytics: updatedAnalytics,
        clearErrorMessage: true,
      ),
    );

    final result = await _churchService.unfollowChurch(churchId: event.churchId);

    result.fold(
      (failure) => emit(
        previous.copyWith(errorMessage: failure.message),
      ),
      (_) {},
    );
  }

  FollowingAnalyticsSummary _toAnalyticsSummary({
    required SubscribersSummary summary,
    required int totalFollowing,
  }) {
    return FollowingAnalyticsSummary(
      period: summary.period,
      totalFollowing: totalFollowing,
      previousPeriodTotal: _previousPeriodTotal(
        totalFollowing,
        summary.growthPercent,
      ),
      growthPercent: summary.growthPercent,
      periodRangeLabel: summary.periodRangeLabel,
      trendPoints: _scaleTrendPoints(summary.trendPoints, totalFollowing),
    );
  }

  int _previousPeriodTotal(int total, double growthPercent) {
    if (total <= 0 || growthPercent <= 0) return 0;
    return (total / (1 + growthPercent / 100)).round().clamp(0, total);
  }

  List<GrowthTrendPoint> _scaleTrendPoints(
    List<GrowthTrendPoint> template,
    int total,
  ) {
    if (template.isEmpty) return template;

    final peak = template.map((point) => point.value).reduce(math.max);
    if (peak <= 0 || total <= 0) {
      return template;
    }

    final scale = total / peak;
    return template
        .map(
          (point) => GrowthTrendPoint(
            label: point.label,
            value: point.value * scale,
          ),
        )
        .toList();
  }
}
