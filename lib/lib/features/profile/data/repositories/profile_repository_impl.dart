import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_range.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_summary.dart';
import 'package:faithconnect/features/profile/domain/entities/account_profile_content.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';
import 'package:faithconnect/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, OrganizationProfile>> getOrganizationProfile() async {
    try {
      final profile = await _remoteDataSource.fetchOrganizationProfile();
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountProfileContent>> getAccountProfileContent({
    required bool churchMode,
  }) async {
    try {
      final content = await _remoteDataSource.fetchAccountProfileContent(
        churchMode: churchMode,
      );
      return Right(content);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GiftSummary>> getGiftSummary(GiftPeriod period) async {
    try {
      final summary = await _remoteDataSource.fetchGiftSummary(period);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscribersSummary>> getSubscribersSummary(
    GiftPeriod period,
  ) async {
    try {
      final summary = await _remoteDataSource.fetchSubscribersSummary(period);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LiveViewersSummary>> getLiveViewersSummary(
    LiveViewersRange range,
  ) async {
    try {
      final summary = await _remoteDataSource.fetchLiveViewersSummary(range);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
