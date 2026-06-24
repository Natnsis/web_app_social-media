import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_detail.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_content.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';
import 'package:faithconnect/features/campaign/data/dto/donate_campaign_dto.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';
import 'package:faithconnect/features/campaign/domain/repositories/campaign_repository.dart';

class CampaignService {
  final CampaignRepository _repository;

  CampaignService(this._repository);

  Future<Either<Failure, CampaignHubContent>> getHubContent(
    CampaignHubFilter filter, {
    String? search,
  }) =>
      _repository.getHubContent(filter, search: search);

  Future<Either<Failure, CampaignDetail>> getCampaignDetail(String id) =>
      _repository.getCampaignDetail(id);

  Future<Either<Failure, String>> launchCampaign(NewCampaignDraft draft) =>
      _repository.launchCampaign(draft);

  Future<Either<Failure, PaymentCheckoutInfo>> donateToCampaign({
    required String campaignId,
    required DonateCampaignDto dto,
  }) =>
      _repository.donateToCampaign(
        campaignId: campaignId,
        dto: dto,
      );

  Future<Either<Failure, String>> checkTransactionStatus(String txRef) =>
      _repository.checkTransactionStatus(txRef);

  Future<Either<Failure, void>> updateCampaign({
    required String campaignId,
    required String title,
    int? goal,
    String? description,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  }) =>
      _repository.updateCampaign(
        campaignId: campaignId,
        title: title,
        goal: goal,
        description: description,
        newMedia: newMedia,
        removeExistingMedia: removeExistingMedia,
      );

  Future<Either<Failure, void>> deleteCampaign(String campaignId) =>
      _repository.deleteCampaign(campaignId);
}
