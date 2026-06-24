// lib/features/analytics/presentation/bloc/analytics_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:faithconnect/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:faithconnect/features/analytics/domain/usecases/get_analytics.dart';
import 'package:faithconnect/core/error/failures.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalytics getAnalytics;

  AnalyticsBloc({required this.getAnalytics}) : super(AnalyticsInitial()) {
    on<AnalyticsRequested>(_onRequested);
  }

  Future<void> _onRequested(AnalyticsRequested event, Emitter<AnalyticsState> emit) async {
    emit(AnalyticsLoading());
    final result = await getAnalytics(event.churchId);
    result.fold(
      (Failure failure) => emit(AnalyticsError(failure.message)),
      (analytics) => emit(AnalyticsLoaded(analytics)),
    );
  }
}
