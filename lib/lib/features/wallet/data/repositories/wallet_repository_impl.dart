import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/exception.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:faithconnect/features/wallet/domain/entities/church_wallet.dart';
import 'package:faithconnect/features/wallet/domain/entities/payment_account.dart';
import 'package:faithconnect/features/wallet/data/dto/create_payment_account_dto.dart';
import 'package:faithconnect/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl({required WalletRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, WalletTransactionPage>> getTransactions({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _remoteDataSource.getTransactions(
        page: page,
        limit: limit,
      );

      final transactions = response.data.map((dto) => dto.toEntity()).toList();

      return Right(WalletTransactionPage(
        transactions: transactions,
        hasNextPage: response.meta.hasNextPage,
        total: response.meta.total,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChurchWallet>> getChurchWallet(String churchId) async {
    try {
      final dto = await _remoteDataSource.getChurchWallet(churchId);
      return Right(dto.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentAccount>>> getPaymentAccounts(String churchId) async {
    try {
      final dtos = await _remoteDataSource.getPaymentAccounts(churchId);
      final accounts = dtos.map((dto) => dto.toEntity()).toList();
      return Right(accounts);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestWithdrawal({
    required String paymentAccountId,
    required double amountEtb,
  }) async {
    try {
      await _remoteDataSource.requestWithdrawal(
        paymentAccountId: paymentAccountId,
        amountEtb: amountEtb,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPaymentAccount(
    String churchId,
    CreatePaymentAccountDto dto,
  ) async {
    try {
      await _remoteDataSource.addPaymentAccount(
        churchId: churchId,
        dto: dto,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
