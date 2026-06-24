// lib/features/analytics/data/repositories/analytics_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/features/analytics/data/dto/analytics_response.dart';
import 'package:faithconnect/features/analytics/data/repositories/analytics_repository.dart';
import 'package:faithconnect/injection.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final Dio _dio;

  AnalyticsRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, AnalyticsResponse>> getAnalytics(
    String churchId,
  ) async {
    try {
      final endpoint = ChurchesApiEndpoint.churchAnalytics.replaceAll(
        '{churchId}',
        churchId,
      );
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Right(AnalyticsResponse.fromJson(data));
      } else {
        return Left(
          ServerFailure(message: 'Failed with status ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
