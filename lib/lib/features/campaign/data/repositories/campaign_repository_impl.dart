import 'package:dartz/dartz.dart';

import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';

import 'package:faithconnect/features/campaign/data/datasources/campaign_remote_datasource.dart';
import 'package:faithconnect/features/campaign/data/dto/donate_campaign_dto.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_detail.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_content.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';
import 'package:faithconnect/features/campaign/domain/repositories/campaign_repository.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';

class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignRemoteDataSource _remoteDataSource;

  CampaignRepositoryImpl({required CampaignRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, CampaignHubContent>> getHubContent(
    CampaignHubFilter filter, {
    String? search,
  }) async {
    try {
      final content = await _remoteDataSource.fetchHubContent(
        filter,
        search: search,
      );
      return Right(content);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CampaignDetail>> getCampaignDetail(String id) async {
    try {
      final detail = await _remoteDataSource.fetchCampaignDetail(id);
      return Right(detail);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> launchCampaign(NewCampaignDraft draft) async {
    try {
      final id = await _remoteDataSource.launchCampaign(draft);
      return Right(id);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentCheckoutInfo>> donateToCampaign({
    required String campaignId,
    required DonateCampaignDto dto,
  }) async {
    try {
      final checkoutInfo = await _remoteDataSource.donateToCampaign(
        campaignId: campaignId,
        dto: dto,
      );
      return Right(checkoutInfo);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> checkTransactionStatus(String txRef) async {
    try {
      final status = await _remoteDataSource.checkTransactionStatus(txRef);
      return Right(status);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCampaign({
    required String campaignId,
    required String title,
    int? goal,
    String? description,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) async {
    try {
      await _remoteDataSource.updateCampaign(
        campaignId: campaignId,
        title: title,
        goal: goal,
        description: description,
        newMedia: newMedia,
        removeExistingMedia: removeExistingMedia,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCampaign(String campaignId) async {
    try {
      await _remoteDataSource.deleteCampaign(campaignId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
