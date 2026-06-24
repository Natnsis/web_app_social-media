import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentAccountsBottomSheet extends StatelessWidget {
  const PaymentAccountsBottomSheet({super.key});

  static Future<void> show(BuildContext context, WalletBloc walletBloc) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: walletBloc,
        child: const PaymentAccountsBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.scaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(top: 16.h, bottom: MediaQuery.of(context).padding.bottom),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state.status == WalletStatus.loading) {
            return SizedBox(
              height: 200.h,
              child: Center(
                child: CircularProgressIndicator(color: colors.brandBlue),
              ),
            );
          }

          final accounts = state.paymentAccounts ?? [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Payment Accounts',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryText,
                ),
              ),
              SizedBox(height: 16.h),
              if (accounts.isEmpty) ...[
                SizedBox(height: 32.h),
                Icon(Icons.account_balance_wallet_outlined, size: 64.r, color: colors.iconMuted),
                SizedBox(height: 16.h),
                Text(
                  'No Payment Accounts',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Add a payment account to receive payouts.',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: colors.mutedText,
                  ),
                ),
                SizedBox(height: 32.h),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: accounts.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return AppCompactCardTile(
                      icon: Icons.account_balance,
                      title: account.accountName,
                      subtitle: '${account.provider} • ${account.accountNumber}',
                      iconBackgroundColor: colors.brandBlue.withValues(alpha: 0.15),
                      iconColor: colors.brandBlue,
                      trailing: account.isVerified
                          ? Icon(Icons.check_circle, color: Colors.green, size: 20.r)
                          : Icon(Icons.pending, color: Colors.orange, size: 20.r),
                    );
                  },
                ),
              ],
              Padding(
                padding: EdgeInsets.all(16.w),
                child: PrimaryButton(
                  text: 'Add Payment Account',
                  onPressed: () {
                    context.pop();
                    AddPaymentAccountBottomSheet.show(context, context.read<WalletBloc>());
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          );
        },
      ),
    );
  }
}

class AddPaymentAccountBottomSheet extends StatefulWidget {
  const AddPaymentAccountBottomSheet({super.key});

  static Future<void> show(BuildContext context, WalletBloc walletBloc) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: walletBloc,
        child: const AddPaymentAccountBottomSheet(),
      ),
    );
  }

  @override
  State<AddPaymentAccountBottomSheet> createState() => _AddPaymentAccountBottomSheetState();
}

class _AddPaymentAccountBottomSheetState extends State<AddPaymentAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _provider = 'CHAPA';
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _providerAccountIdController = TextEditingController();

  final List<String> _providers = ['CHAPA', 'TELEBIRR', 'CBE_BIRR'];

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _providerAccountIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<WalletBloc>().add(
        AddPaymentAccount(
          provider: _provider,
          accountName: _accountNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          providerAccountId: _providerAccountIdController.text.trim().isEmpty 
              ? null 
              : _providerAccountIdController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return BlocListener<WalletBloc, WalletState>(
      listenWhen: (previous, current) =>
          previous.isAddingPaymentAccount != current.isAddingPaymentAccount,
      listener: (context, state) {
        if (!state.isAddingPaymentAccount) {
          if (state.addPaymentAccountSuccess) {
            context.pop();
            showSuccess(context, 'Payment account added successfully');
            // Reopen the list sheet
            PaymentAccountsBottomSheet.show(context, context.read<WalletBloc>());
          } else if (state.addPaymentAccountErrorMessage != null) {
            showError(context, state.addPaymentAccountErrorMessage!);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.scaffoldBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Add Payment Account',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Provider',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.primaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  initialValue: _provider,
                  items: _providers.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _provider = val);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _accountNameController,
                  decoration: InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g. Bethel Church',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Account Number',
                    hintText: 'e.g. 1000012345678',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _providerAccountIdController,
                  decoration: InputDecoration(
                    labelText: 'Provider Account ID (Optional)',
                    hintText: 'e.g. chp_abc123',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 32.h),
                BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'Save Account',
                      isLoading: state.isAddingPaymentAccount,
                      onPressed: _submit,
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
