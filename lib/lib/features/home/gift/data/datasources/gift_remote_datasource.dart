import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_catalog.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/features/home/gift/data/dto/gift_item_dto.dart';
import 'package:faithconnect/features/home/gift/data/dto/send_gift_dto.dart';
import 'package:faithconnect/features/home/gift/data/mock/gift_mock_data.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_hub_content.dart';
import 'package:faithconnect/features/home/gift/domain/entities/live_gift_receipt.dart';

abstract class GiftRemoteDataSource {
  Future<GiftHubContent> fetchHubContent();
  Future<LiveGiftReceipt> sendLiveGift({
    required String streamId,
    required String giftItemId,
  });
  Future<PaymentCheckoutInfo> sendGift(SendGiftDto dto);
  Future<String> checkTransactionStatus(String txRef);
}

class GiftRemoteDataSourceImpl implements GiftRemoteDataSource {
  final Dio _dio;

  GiftRemoteDataSourceImpl(this._dio);

  @override
  Future<GiftHubContent> fetchHubContent() async {
    try {
      final response = await _dio.get('/v1/gifting/catalog');
      final dataList = response.data['data'] as List<dynamic>;
      final items = dataList
          .map((e) => GiftItemDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      final catalog = GiftCatalog(items: items, balanceEtb: 1250.0);

      return GiftHubContent(
        title: 'Send a Gift',
        catalog: catalog,
      );
    } catch (e, stack) {
      FaithLogger.e('GiftRemoteDataSource', 'Failed to fetch gift catalog', e);
      if (e is DioException) {
        throw Exception(ApiErrorMapper.messageFrom(e));
      }
      rethrow;
    }
  }

  @override
  Future<LiveGiftReceipt> sendLiveGift({
    required String streamId,
    required String giftItemId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    try {
      return GiftMockData.sendLiveGift(
        streamId: streamId,
        giftItemId: giftItemId,
      );
    } on InsufficientGiftCoinsException {
      throw InsufficientGiftCoinsException();
    }
  }

  @override
  Future<PaymentCheckoutInfo> sendGift(SendGiftDto dto) async {
    try {
      final response = await _dio.post<dynamic>(
        BillingApiEndpoint.gifts,
        data: dto.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return PaymentCheckoutInfo.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<String> checkTransactionStatus(String txRef) async {
    try {
      final response = await _dio.get<dynamic>(
        BillingApiEndpoint.transactionStatus(txRef),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return data['status'] as String? ?? 'UNKNOWN';
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
