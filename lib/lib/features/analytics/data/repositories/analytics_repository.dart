// lib/features/analytics/data/repositories/analytics_repository.dart
import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/analytics/data/dto/analytics_response.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsResponse>> getAnalytics(String churchId);
}
