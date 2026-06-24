import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:faithconnect/features/wallet/presentation/widgets/wallet_transaction_card.dart';
import 'package:faithconnect/features/wallet/presentation/widgets/withdraw_funds_dialog.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletBloc>()..add(const FetchWalletTransactions()),
      child: const _WalletPageView(),
    );
  }
}

class _WalletPageView extends StatelessWidget {
  const _WalletPageView();

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return BlocListener<WalletBloc, WalletState>(
      listenWhen: (previous, current) =>
          previous.withdrawalSuccess != current.withdrawalSuccess ||
          previous.withdrawalErrorMessage != current.withdrawalErrorMessage,
      listener: (context, state) {
        if (state.withdrawalSuccess) {
          showSuccess(context, 'Withdrawal successful!');
        } else if (state.withdrawalErrorMessage != null) {
          showError(context, state.withdrawalErrorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: colors.scaffoldBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.iconPrimary,
              size: 20.r,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Wallet',
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.scaffoldBackground,
                isDark ? colors.navBarBackground : colors.tagBackground,
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            children: [
              const _WalletBalanceCard(),
              SizedBox(height: 28.h),
              Text(
                'Transactions',
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 16.h),
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state.status == WalletStatus.loading &&
                      state.transactions.isEmpty) {
                    return const _TransactionListSkeleton();
                  }

                  if (state.status == WalletStatus.error &&
                      state.transactions.isEmpty) {
                    return _WalletMessageState(
                      icon: Iconsax.warning_2,
                      message:
                          state.errorMessage ?? 'Failed to load transactions',
                      isError: true,
                    );
                  }

                  if (state.transactions.isEmpty) {
                    return const _WalletMessageState(
                      icon: Iconsax.receipt_2,
                      message: 'No transactions yet.',
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.transactions.length +
                        (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index == state.transactions.length) {
                        return Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colors.brandBlue,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      final tx = state.transactions[index];
                      var title = tx.title ?? 'Wallet Transaction';
                      if (tx.title == null || tx.title!.isEmpty) {
                        if (tx.transactionType ==
                            WalletTransactionType.campaignDonation) {
                          title = 'Campaign';
                        } else if (tx.transactionType ==
                            WalletTransactionType.gift) {
                          title = 'Gift';
                        }
                      }

                      return WalletTransactionCard(
                        type: tx.transactionType,
                        title: title,
                        subtitle: tx.subtitle,
                        iconUrl: tx.iconUrl,
                        amount:
                            'ETB ${NumberFormat('#,##0.00').format(tx.amount)}',
                        status: tx.status,
                        dateString: DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(tx.createdAt),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        final wallet = state.churchWallet;
        final balanceText = wallet != null
            ? 'ETB ${NumberFormat('#,##0.00').format(wallet.balanceEtb)}'
            : 'ETB 0.00';

        final cardGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colors.brandBlue,
                  colors.sidebarSurface,
                ]
              : [
                  colors.brandBlue,
                  colors.brandSky,
                ],
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: cardGradient,
            boxShadow: [
              BoxShadow(
                color: colors.brandBlue.withValues(alpha: isDark ? 0.25 : 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Iconsax.wallet_3,
                            color: Colors.white,
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Wallet Balance',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    if (state.status == WalletStatus.loading && wallet == null)
                      Shimmer.fromColors(
                        baseColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.45),
                        child: Container(
                          height: 34.h,
                          width: 170.w,
                          decoration: BoxDecoration(
                            color: colors.shimmerHighlight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      )
                    else
                      Text(
                        balanceText,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                    SizedBox(height: 18.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12.r),
                        child: InkWell(
                          onTap: () {
                            if (wallet == null || state.isWithdrawing) return;
                            WithdrawFundsDialog.show(
                              context,
                              maxBalance: wallet.balanceEtb,
                              paymentAccounts: state.paymentAccounts,
                            );
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 9.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.isWithdrawing
                                      ? 'Withdrawing...'
                                      : 'Withdraw',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                if (state.isWithdrawing)
                                  SizedBox(
                                    width: 14.r,
                                    height: 14.r,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  Icon(
                                    Iconsax.export_1,
                                    color: Colors.white,
                                    size: 14.r,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }
}

class _WalletMessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isError;

  const _WalletMessageState({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final tint = isError ? colors.error : colors.mutedText;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(icon, size: 40.r, color: tint.withValues(alpha: 0.8)),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: tint,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionListSkeleton extends StatelessWidget {
  const _TransactionListSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: colors.divider),
          ),
          child: Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: colors.shimmerHighlight,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Container(
                        width: 180.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: colors.shimmerHighlight,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 120.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: colors.shimmerHighlight,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
