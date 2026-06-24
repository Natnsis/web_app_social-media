import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_detail.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_content.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/campaign/data/dto/donate_campaign_dto.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';

abstract class CampaignRepository {
  Future<Either<Failure, CampaignHubContent>> getHubContent(
    CampaignHubFilter filter, {
    String? search,
  });

  Future<Either<Failure, CampaignDetail>> getCampaignDetail(String id);

  Future<Either<Failure, String>> launchCampaign(NewCampaignDraft draft);

  Future<Either<Failure, PaymentCheckoutInfo>> donateToCampaign({
    required String campaignId,
    required DonateCampaignDto dto,
  });

  Future<Either<Failure, String>> checkTransactionStatus(String txRef);

  Future<Either<Failure, void>> updateCampaign({
    required String campaignId,
    required String title,
    int? goal,
    String? description,
    UploadedMedia? newMedia,
    bool removeExistingMedia = false,
  });

  Future<Either<Failure, void>> deleteCampaign(String campaignId);
}
