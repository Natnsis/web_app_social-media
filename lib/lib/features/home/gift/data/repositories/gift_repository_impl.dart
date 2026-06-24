import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';
import 'package:faithconnect/features/home/gift/data/datasources/gift_remote_datasource.dart';
import 'package:faithconnect/features/home/gift/data/dto/send_gift_dto.dart';
import 'package:faithconnect/features/home/gift/data/mock/gift_mock_data.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_hub_content.dart';
import 'package:faithconnect/features/home/gift/domain/entities/live_gift_receipt.dart';
import 'package:faithconnect/features/home/gift/domain/repositories/gift_repository.dart';

class GiftRepositoryImpl implements GiftRepository {
  final GiftRemoteDataSource remoteDataSource;

  GiftRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, GiftHubContent>> getHubContent() async {
    try {
      final content = await remoteDataSource.fetchHubContent();
      return Right(content);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LiveGiftReceipt>> sendLiveGift({
    required String streamId,
    required String giftItemId,
  }) async {
    try {
      final receipt = await remoteDataSource.sendLiveGift(
        streamId: streamId,
        giftItemId: giftItemId,
      );
      return Right(receipt);
    } on InsufficientGiftCoinsException {
      return const Left(
        ServiceFailure(message: 'Not enough coins for this gift'),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentCheckoutInfo>> sendGift(SendGiftDto dto) async {
    try {
      final info = await remoteDataSource.sendGift(dto);
      return Right(info);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> checkTransactionStatus(String txRef) async {
    try {
      final status = await remoteDataSource.checkTransactionStatus(txRef);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
