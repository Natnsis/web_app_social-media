// lib/features/analytics/presentation/bloc/analytics_event.dart
import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsRequested extends AnalyticsEvent {
  final String churchId;

  const AnalyticsRequested(this.churchId);

  @override
  List<Object?> get props => [churchId];
}
