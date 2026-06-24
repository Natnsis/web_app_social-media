import 'package:equatable/equatable.dart';

enum WalletTransactionType {
  campaignDonation,
  gift,
  unknown,
}

class WalletTransaction extends Equatable {
  final String id;
  final String userId;
  final WalletTransactionType transactionType;
  final double amount;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final String? title;
  final String? subtitle;
  final String? iconUrl;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.metadata,
    this.title,
    this.subtitle,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        transactionType,
        amount,
        status,
        createdAt,
        metadata,
        title,
        subtitle,
        iconUrl,
      ];
}

/// A paginated list of wallet transactions.
class WalletTransactionPage extends Equatable {
  final List<WalletTransaction> transactions;
  final bool hasNextPage;
  final int total;

  const WalletTransactionPage({
    required this.transactions,
    required this.hasNextPage,
    required this.total,
  });

  @override
  List<Object?> get props => [transactions, hasNextPage, total];
}
