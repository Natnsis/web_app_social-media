import 'package:equatable/equatable.dart';

class ChurchWallet extends Equatable {
  final String id;
  final String churchId;
  final double balanceEtb;
  final double totalEarnedEtb;
  final double totalWithdrawnEtb;
  final double totalCommissionPaidEtb;
  final DateTime? lastTransactionAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pendingWithdrawalsCount;
  final double pendingWithdrawalsAmountEtb;

  const ChurchWallet({
    required this.id,
    required this.churchId,
    required this.balanceEtb,
    required this.totalEarnedEtb,
    required this.totalWithdrawnEtb,
    required this.totalCommissionPaidEtb,
    this.lastTransactionAt,
    required this.createdAt,
    required this.updatedAt,
    required this.pendingWithdrawalsCount,
    required this.pendingWithdrawalsAmountEtb,
  });

  @override
  List<Object?> get props => [
        id,
        churchId,
        balanceEtb,
        totalEarnedEtb,
        totalWithdrawnEtb,
        totalCommissionPaidEtb,
        lastTransactionAt,
        createdAt,
        updatedAt,
        pendingWithdrawalsCount,
        pendingWithdrawalsAmountEtb,
      ];
}
