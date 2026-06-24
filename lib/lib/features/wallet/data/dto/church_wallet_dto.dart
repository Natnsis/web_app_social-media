import 'package:faithconnect/features/wallet/domain/entities/church_wallet.dart';

class ChurchWalletDto {
  final String id;
  final String churchId;
  final num balanceEtb;
  final num totalEarnedEtb;
  final num totalWithdrawnEtb;
  final num totalCommissionPaidEtb;
  final DateTime? lastTransactionAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pendingWithdrawalsCount;
  final num pendingWithdrawalsAmountEtb;

  ChurchWalletDto({
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

  factory ChurchWalletDto.fromJson(Map<String, dynamic> json) {
    return ChurchWalletDto(
      id: json['id'] as String? ?? '',
      churchId: json['churchId'] as String? ?? '',
      balanceEtb: json['balanceEtb'] as num? ?? 0,
      totalEarnedEtb: json['totalEarnedEtb'] as num? ?? 0,
      totalWithdrawnEtb: json['totalWithdrawnEtb'] as num? ?? 0,
      totalCommissionPaidEtb: json['totalCommissionPaidEtb'] as num? ?? 0,
      lastTransactionAt: json['lastTransactionAt'] != null
          ? DateTime.parse(json['lastTransactionAt'] as String).toLocal()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toLocal()
          : DateTime.now(),
      pendingWithdrawalsCount: json['pendingWithdrawalsCount'] as int? ?? 0,
      pendingWithdrawalsAmountEtb:
          json['pendingWithdrawalsAmountEtb'] as num? ?? 0,
    );
  }

  ChurchWallet toEntity() {
    return ChurchWallet(
      id: id,
      churchId: churchId,
      balanceEtb: balanceEtb.toDouble(),
      totalEarnedEtb: totalEarnedEtb.toDouble(),
      totalWithdrawnEtb: totalWithdrawnEtb.toDouble(),
      totalCommissionPaidEtb: totalCommissionPaidEtb.toDouble(),
      lastTransactionAt: lastTransactionAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pendingWithdrawalsCount: pendingWithdrawalsCount,
      pendingWithdrawalsAmountEtb: pendingWithdrawalsAmountEtb.toDouble(),
    );
  }
}
