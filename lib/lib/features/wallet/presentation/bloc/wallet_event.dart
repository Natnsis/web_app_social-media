import 'package:equatable/equatable.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class FetchWalletTransactions extends WalletEvent {
  final bool isRefresh;

  const FetchWalletTransactions({this.isRefresh = false});

  @override
  List<Object> get props => [isRefresh];
}

class FetchChurchWalletBalance extends WalletEvent {
  const FetchChurchWalletBalance();
}

class RequestWalletWithdrawal extends WalletEvent {
  final String paymentAccountId;
  final double amountEtb;

  const RequestWalletWithdrawal({
    required this.paymentAccountId,
    required this.amountEtb,
  });

  @override
  List<Object> get props => [paymentAccountId, amountEtb];
}

class AddPaymentAccount extends WalletEvent {
  final String provider;
  final String accountName;
  final String accountNumber;
  final String? providerAccountId;

  const AddPaymentAccount({
    required this.provider,
    required this.accountName,
    required this.accountNumber,
    this.providerAccountId,
  });

  @override
  List<Object> get props => [
        provider,
        accountName,
        accountNumber,
        providerAccountId ?? '',
      ];
}
