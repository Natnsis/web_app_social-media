import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:faithconnect/features/wallet/domain/entities/church_wallet.dart';
import 'package:faithconnect/features/wallet/domain/entities/payment_account.dart';
import 'package:faithconnect/features/wallet/data/dto/create_payment_account_dto.dart';
import 'package:faithconnect/features/wallet/domain/repositories/wallet_repository.dart';

class WalletService {
  final WalletRepository _repository;

  WalletService(this._repository);

  Future<Either<Failure, WalletTransactionPage>> getTransactions({
    required int page,
    int limit = 20,
  }) {
    return _repository.getTransactions(page: page, limit: limit);
  }

  Future<Either<Failure, ChurchWallet>> getChurchWallet(String churchId) {
    return _repository.getChurchWallet(churchId);
  }

  Future<Either<Failure, List<PaymentAccount>>> getPaymentAccounts(String churchId) {
    return _repository.getPaymentAccounts(churchId);
  }

  Future<Either<Failure, void>> requestWithdrawal({
    required String paymentAccountId,
    required double amountEtb,
  }) {
    return _repository.requestWithdrawal(
      paymentAccountId: paymentAccountId,
      amountEtb: amountEtb,
    );
  }

  Future<Either<Failure, void>> addPaymentAccount({
    required String churchId,
    required CreatePaymentAccountDto dto,
  }) {
    return _repository.addPaymentAccount(churchId, dto);
  }
}
