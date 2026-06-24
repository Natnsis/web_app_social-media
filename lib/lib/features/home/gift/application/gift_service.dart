import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_hub_content.dart';
import 'package:faithconnect/features/home/gift/domain/entities/live_gift_receipt.dart';
import 'package:faithconnect/features/home/gift/data/dto/send_gift_dto.dart';
import 'package:faithconnect/features/home/gift/domain/repositories/gift_repository.dart';

class GiftService {
  final GiftRepository _repository;

  GiftService(this._repository);

  Future<Either<Failure, GiftHubContent>> getHubContent() =>
      _repository.getHubContent();

  Future<Either<Failure, LiveGiftReceipt>> sendLiveGift({
    required String streamId,
    required String giftItemId,
  }) =>
      _repository.sendLiveGift(
        streamId: streamId,
        giftItemId: giftItemId,
      );

  Future<Either<Failure, PaymentCheckoutInfo>> sendGift(SendGiftDto dto) =>
      _repository.sendGift(dto);

  Future<Either<Failure, String>> checkTransactionStatus(String txRef) =>
      _repository.checkTransactionStatus(txRef);
}
