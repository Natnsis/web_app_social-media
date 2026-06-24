import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:faithconnect/features/wallet/domain/entities/church_wallet.dart';
import 'package:faithconnect/features/wallet/domain/entities/payment_account.dart';
import 'package:faithconnect/features/wallet/data/dto/create_payment_account_dto.dart';

abstract class WalletRepository {
  /// Fetches a paginated list of user billing transactions.
  Future<Either<Failure, WalletTransactionPage>> getTransactions({
    required int page,
    required int limit,
  });

  /// Fetches the church wallet details.
  Future<Either<Failure, ChurchWallet>> getChurchWallet(String churchId);

  /// Fetches payment accounts for the church.
  Future<Either<Failure, List<PaymentAccount>>> getPaymentAccounts(String churchId);

  /// Requests a withdrawal.
  Future<Either<Failure, void>> requestWithdrawal({
    required String paymentAccountId,
    required double amountEtb,
  });

  /// Adds a new payment account for the church.
  Future<Either<Failure, void>> addPaymentAccount(
    String churchId,
    CreatePaymentAccountDto dto,
  );
}
