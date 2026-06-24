import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/features/wallet/data/dto/create_payment_account_dto.dart';
import 'package:faithconnect/features/wallet/application/wallet_service.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletService _walletService;
  static const int _limit = 20;

  WalletBloc({required WalletService walletService})
      : _walletService = walletService,
        super(const WalletState()) {
    on<FetchWalletTransactions>(_onFetchWalletTransactions);
    on<FetchChurchWalletBalance>(_onFetchChurchWalletBalance);
    on<RequestWalletWithdrawal>(_onRequestWalletWithdrawal);
    on<AddPaymentAccount>(_onAddPaymentAccount);
  }

  Future<void> _onFetchWalletTransactions(
    FetchWalletTransactions event,
    Emitter<WalletState> emit,
  ) async {
    if (state.hasReachedMax && !event.isRefresh) return;

    if (event.isRefresh) {
      emit(state.copyWith(
        status: WalletStatus.loading,
        transactions: [],
        hasReachedMax: false,
        currentPage: 1,
      ));
    } else {
      if (state.status == WalletStatus.initial) {
        emit(state.copyWith(status: WalletStatus.loading));
      } else {
        emit(state.copyWith(isLoadingMore: true));
      }
    }

    final page = event.isRefresh ? 1 : state.currentPage;

    // Launch both fetches concurrently
    final walletFuture = (event.isRefresh || state.churchWallet == null)
        ? () async {
            final user = await SharedPrefsService.getUser();
            final churchId = user?.churchId;
            if (churchId != null && churchId.isNotEmpty) {
              return await _walletService.getChurchWallet(churchId);
            }
            return null;
          }()
        : Future.value(null);

    final paymentAccountsFuture = (event.isRefresh || state.paymentAccounts == null)
        ? () async {
            final user = await SharedPrefsService.getUser();
            final churchId = user?.churchId;
            if (churchId != null && churchId.isNotEmpty) {
              return await _walletService.getPaymentAccounts(churchId);
            }
            return null;
          }()
        : Future.value(null);

    final transactionsFuture = _walletService.getTransactions(
      page: page,
      limit: _limit,
    );

    final results = await Future.wait([walletFuture, paymentAccountsFuture, transactionsFuture]);

    // Handle Wallet Result
    final walletResult = results[0] as dynamic;
    if (walletResult != null && !emit.isDone) {
      walletResult.fold(
        (failure) {}, // Optional: handle error quietly
        (wallet) {
          emit(state.copyWith(churchWallet: wallet)); // Dart will infer 'wallet' as dynamic and cast automatically, or we can use explicit types.
        },
      );
    }

    // Handle Payment Accounts Result
    final paymentAccountsResult = results[1] as dynamic;
    if (paymentAccountsResult != null && !emit.isDone) {
      paymentAccountsResult.fold(
        (failure) {}, // Optional: handle error quietly
        (accounts) {
          emit(state.copyWith(paymentAccounts: accounts));
        },
      );
    }

    // Handle Transactions Result
    final result = results[2] as dynamic; // It's an Either<Failure, WalletTransactionPage>

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.message,
          isLoadingMore: false,
        ));
      },
      (pageData) {
        if (pageData.transactions.isEmpty) {
          emit(state.copyWith(
            status: WalletStatus.loaded,
            hasReachedMax: true,
            isLoadingMore: false,
          ));
        } else {
          final List<WalletTransaction> newTransactions = [];
          if (!event.isRefresh) {
            newTransactions.addAll(state.transactions);
          }
          newTransactions.addAll(pageData.transactions);

          emit(state.copyWith(
            status: WalletStatus.loaded,
            transactions: newTransactions,
            hasReachedMax: !pageData.hasNextPage,
            currentPage: page + 1,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onFetchChurchWalletBalance(
    FetchChurchWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    if (state.churchWallet != null) return;

    emit(state.copyWith(status: WalletStatus.loading));
    final user = await SharedPrefsService.getUser();
    final churchId = user?.churchId;
    if (churchId != null && churchId.isNotEmpty) {
      final result = await _walletService.getChurchWallet(churchId);
      // Await the fold to ensure emits happen before handler finishes
      await result.fold(
        (failure) async {
          emit(state.copyWith(
            status: WalletStatus.error,
            errorMessage: failure.message,
          ));
        },
        (wallet) async {
          // fetch payment accounts
          final accountsResult = await _walletService.getPaymentAccounts(churchId);
          await accountsResult.fold(
            (failure) async {
              emit(state.copyWith(
                status: WalletStatus.loaded,
                churchWallet: wallet,
              ));
            },
            (accounts) async {
              emit(state.copyWith(
                status: WalletStatus.loaded,
                churchWallet: wallet,
                paymentAccounts: accounts,
              ));
            },
          );
        },
      );
    } else {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: 'Church ID not found',
      ));
    }
  }

  Future<void> _onRequestWalletWithdrawal(
    RequestWalletWithdrawal event,
    Emitter<WalletState> emit,
  ) async {
    if (state.isWithdrawing) return;

    emit(state.copyWith(
      isWithdrawing: true,
      withdrawalSuccess: false,
      withdrawalErrorMessage: null, // Reset error
    ));

    final result = await _walletService.requestWithdrawal(
      paymentAccountId: event.paymentAccountId,
      amountEtb: event.amountEtb,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isWithdrawing: false,
          withdrawalSuccess: false,
          withdrawalErrorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          isWithdrawing: false,
          withdrawalSuccess: true,
          withdrawalErrorMessage: null,
        ));
        
        // Refresh balance after successful withdrawal
        add(const FetchChurchWalletBalance());
        add(const FetchWalletTransactions(isRefresh: true));
      },
    );
  }

  Future<void> _onAddPaymentAccount(
    AddPaymentAccount event,
    Emitter<WalletState> emit,
  ) async {
    if (state.isAddingPaymentAccount) return;

    emit(state.copyWith(
      isAddingPaymentAccount: true,
      addPaymentAccountSuccess: false,
      addPaymentAccountErrorMessage: null, // Reset error
    ));

    final user = await SharedPrefsService.getUser();
    final churchId = user?.churchId;
    if (churchId == null || churchId.isEmpty) {
      emit(state.copyWith(
        isAddingPaymentAccount: false,
        addPaymentAccountSuccess: false,
        addPaymentAccountErrorMessage: 'Church ID not found',
      ));
      return;
    }

    final result = await _walletService.addPaymentAccount(
      churchId: churchId,
      dto: CreatePaymentAccountDto(
        provider: event.provider,
        accountName: event.accountName,
        accountNumber: event.accountNumber,
        providerAccountId: event.providerAccountId,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isAddingPaymentAccount: false,
          addPaymentAccountSuccess: false,
          addPaymentAccountErrorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          isAddingPaymentAccount: false,
          addPaymentAccountSuccess: true,
          addPaymentAccountErrorMessage: null,
        ));

        // Refresh payment accounts after successful add
        add(const FetchChurchWalletBalance());
      },
    );
  }
}
