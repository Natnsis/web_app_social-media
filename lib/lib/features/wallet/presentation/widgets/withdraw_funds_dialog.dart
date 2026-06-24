import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/wallet/domain/entities/payment_account.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

/// Withdrawal dialog styled to match core modals ([ConfirmationModal]).
class WithdrawFundsDialog extends StatefulWidget {
  final double maxBalance;
  final List<PaymentAccount>? paymentAccounts;

  const WithdrawFundsDialog({
    super.key,
    required this.maxBalance,
    this.paymentAccounts,
  });

  static Future<void> show(
    BuildContext context, {
    required double maxBalance,
    List<PaymentAccount>? paymentAccounts,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => WithdrawFundsDialog(
        maxBalance: maxBalance,
        paymentAccounts: paymentAccounts,
      ),
    );
  }

  @override
  State<WithdrawFundsDialog> createState() => _WithdrawFundsDialogState();
}

class _WithdrawFundsDialogState extends State<WithdrawFundsDialog> {
  late final TextEditingController _amountController;
  String? _selectedAccountId;

  List<PaymentAccount> get _accounts => widget.paymentAccounts ?? [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '1000');
    if (_accounts.isNotEmpty) {
      _selectedAccountId = _accounts.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(FaithAppColors colors) {
    return InputDecoration(
      filled: true,
      fillColor: colors.inputBackground,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colors.brandBlue, width: 1.5),
      ),
    );
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final accountId = _selectedAccountId ?? '';

    if (amount <= 0 || amount > widget.maxBalance) {
      showError(
        context,
        'Enter a valid amount up to ETB ${widget.maxBalance.toStringAsFixed(2)}.',
      );
      return;
    }

    if (accountId.isEmpty) {
      showError(context, 'Select a payment account to continue.');
      return;
    }

    Navigator.of(context).pop();
    context.read<WalletBloc>().add(
          RequestWalletWithdrawal(
            paymentAccountId: accountId,
            amountEtb: amount,
          ),
        );
  }

  Widget _selectedAccountLabel(PaymentAccount account, FaithAppColors colors) {
    return Text(
      '${account.accountName} • ${account.provider}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        color: colors.primaryText,
      ),
    );
  }

  Widget _accountMenuItem(
    PaymentAccount account,
    FaithAppColors colors,
  ) {
    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: colors.brandBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Iconsax.bank,
              size: 16.r,
              color: colors.brandBlue,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: account.accountName,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.primaryText,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: '\n${account.provider} • ${account.accountNumber}',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: colors.mutedText,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final maxLabel = NumberFormat('#,##0.00').format(widget.maxBalance);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      backgroundColor: colors.cardBackground,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.r),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24.w,
            24.h,
            24.w,
            24.h + viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: colors.brandBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.brandBlue.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Iconsax.wallet_minus,
                size: 32.r,
                color: colors.brandBlue,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Withdraw Funds',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: colors.primaryText,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Transfer from your wallet to a linked payment account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                height: 1.45,
                color: colors.mutedText,
              ),
            ),
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Amount',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.secondaryText,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
              decoration: _fieldDecoration(colors).copyWith(
                prefixText: 'ETB ',
                prefixStyle: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.mutedText,
                ),
                hintText: '0.00',
                hintStyle: GoogleFonts.inter(color: colors.mutedText),
              ),
            ),
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Available: ETB $maxLabel',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: colors.brandSky,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment account',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.secondaryText,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            if (_accounts.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, size: 18.r, color: colors.error),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'No payment accounts found. Add one first.',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: colors.error,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedAccountId,
                isExpanded: true,
                isDense: true,
                itemHeight: 56.h,
                menuMaxHeight: 240.h,
                dropdownColor: colors.cardBackground,
                icon: Icon(
                  Iconsax.arrow_down_1,
                  size: 18.r,
                  color: colors.iconMuted,
                ),
                selectedItemBuilder: (context) {
                  return _accounts
                      .map(
                        (account) => Align(
                          alignment: Alignment.centerLeft,
                          child: _selectedAccountLabel(account, colors),
                        ),
                      )
                      .toList();
                },
                items: _accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: _accountMenuItem(account, colors),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedAccountId = value),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: colors.primaryText,
                ),
                decoration: _fieldDecoration(colors),
              ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.brandBlue,
                          colors.brandBlue.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(100.r),
                      boxShadow: [
                        BoxShadow(
                          color: colors.brandBlue.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _accounts.isEmpty ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                      child: Text(
                        'Withdraw',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
