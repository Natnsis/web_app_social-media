import 'package:dio/dio.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/features/wallet/data/dto/wallet_transaction_dto.dart';
import 'package:faithconnect/features/wallet/data/dto/church_wallet_dto.dart';
import 'package:faithconnect/features/wallet/data/dto/payment_account_dto.dart';
import 'package:faithconnect/features/wallet/data/dto/create_payment_account_dto.dart';

abstract class WalletRemoteDataSource {
  Future<ApiListResponse<WalletTransactionDto>> getTransactions({
    required int page,
    required int limit,
  });

  Future<ChurchWalletDto> getChurchWallet(String churchId);

  Future<List<PaymentAccountDto>> getPaymentAccounts(String churchId);

  Future<void> requestWithdrawal({
    required String paymentAccountId,
    required double amountEtb,
  });

  Future<void> addPaymentAccount({
    required String churchId,
    required CreatePaymentAccountDto dto,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio _dio;

  WalletRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiListResponse<WalletTransactionDto>> getTransactions({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/billing/transactions',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return ApiListResponse.parse<WalletTransactionDto>(
        response.data,
        (json) => WalletTransactionDto.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.exceptionFrom(e);
    }
  }

  @override
  Future<ChurchWalletDto> getChurchWallet(String churchId) async {
    try {
      final response = await _dio.get('/v1/billing/churches/$churchId/wallet');
      final responseData = response.data;
      final data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;
      return ChurchWalletDto.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorMapper.exceptionFrom(e);
    }
  }

  @override
  Future<List<PaymentAccountDto>> getPaymentAccounts(String churchId) async {
    try {
      final response = await _dio.get('/v1/churches/$churchId/payment-accounts');
      final responseData = response.data;
      List data = [];
      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map) {
        data = (responseData['results'] ?? responseData['data'] ?? []) as List;
      }
      return data.map((json) => PaymentAccountDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.exceptionFrom(e);
    }
  }

  @override
  Future<void> requestWithdrawal({
    required String paymentAccountId,
    required double amountEtb,
  }) async {
    try {
      await _dio.post(
        '/v1/billing/withdrawals',
        data: {
          "paymentAccountId": paymentAccountId,
          "amountEtb": amountEtb,
        },
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.exceptionFrom(e);
    }
  }

  @override
  Future<void> addPaymentAccount({
    required String churchId,
    required CreatePaymentAccountDto dto,
  }) async {
    try {
      await _dio.post(
        '/v1/churches/$churchId/payment-accounts',
        data: dto.toJson(),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.exceptionFrom(e);
    }
  }
}
