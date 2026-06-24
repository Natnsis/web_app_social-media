import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:faithconnect/features/wallet/domain/entities/church_wallet.dart';
import 'package:faithconnect/features/wallet/domain/entities/payment_account.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final List<WalletTransaction> transactions;
  final ChurchWallet? churchWallet;
  final List<PaymentAccount>? paymentAccounts;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final bool isLoadingMore;
  final bool isWithdrawing;
  final bool withdrawalSuccess;
  final String? withdrawalErrorMessage;
  final bool isAddingPaymentAccount;
  final bool addPaymentAccountSuccess;
  final String? addPaymentAccountErrorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.transactions = const [],
    this.churchWallet,
    this.paymentAccounts,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.isWithdrawing = false,
    this.withdrawalSuccess = false,
    this.withdrawalErrorMessage,
    this.isAddingPaymentAccount = false,
    this.addPaymentAccountSuccess = false,
    this.addPaymentAccountErrorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    List<WalletTransaction>? transactions,
    ChurchWallet? churchWallet,
    List<PaymentAccount>? paymentAccounts,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    bool? isLoadingMore,
    bool? isWithdrawing,
    bool? withdrawalSuccess,
    String? withdrawalErrorMessage,
    bool? isAddingPaymentAccount,
    bool? addPaymentAccountSuccess,
    String? addPaymentAccountErrorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      churchWallet: churchWallet ?? this.churchWallet,
      paymentAccounts: paymentAccounts ?? this.paymentAccounts,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      withdrawalSuccess: withdrawalSuccess ?? this.withdrawalSuccess,
      withdrawalErrorMessage: withdrawalErrorMessage, // intentional to allow reset
      isAddingPaymentAccount: isAddingPaymentAccount ?? this.isAddingPaymentAccount,
      addPaymentAccountSuccess: addPaymentAccountSuccess ?? this.addPaymentAccountSuccess,
      addPaymentAccountErrorMessage: addPaymentAccountErrorMessage, // intentional to allow reset
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        churchWallet,
        paymentAccounts,
        errorMessage,
        hasReachedMax,
        currentPage,
        isLoadingMore,
        isWithdrawing,
        withdrawalSuccess,
        withdrawalErrorMessage,
        isAddingPaymentAccount,
        addPaymentAccountSuccess,
        addPaymentAccountErrorMessage,
      ];
}
