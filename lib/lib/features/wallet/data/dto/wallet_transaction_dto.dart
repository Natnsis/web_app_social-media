import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';

class WalletTransactionDto {
  final String id;
  final String userId;
  final String transactionType;
  final num amount;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final String? title;
  final String? subtitle;
  final String? iconUrl;

  WalletTransactionDto({
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

  factory WalletTransactionDto.fromJson(Map<String, dynamic> json) {
    final type = json['transactionType'] as String? ?? '';
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final providerResponse = json['providerResponse'] as Map<String, dynamic>?;
    final giftTransaction = json['giftTransaction'] as Map<String, dynamic>?;

    String? parsedTitle;
    String? parsedSubtitle;
    String? parsedIconUrl;

    if (type.toUpperCase() == 'GIFT') {
      parsedTitle = providerResponse?['customization']?['title'] as String? ??
          giftTransaction?['giftCatalogItem']?['name'] as String? ??
          'Gift Sent';
      parsedSubtitle = providerResponse?['customization']?['description'] as String? ??
          metadata['message'] as String?;
      parsedIconUrl = giftTransaction?['giftCatalogItem']?['iconUrl'] as String?;
    } else if (type.toUpperCase() == 'CAMPAIGN_DONATION') {
      parsedTitle = 'Campaign Donation';
      parsedSubtitle = metadata['donorMessage'] as String?;
    }

    return WalletTransactionDto(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      transactionType: type,
      amount: json['amount'] as num? ?? 0,
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
      metadata: metadata,
      title: parsedTitle,
      subtitle: parsedSubtitle,
      iconUrl: parsedIconUrl,
    );
  }

  WalletTransaction toEntity() {
    return WalletTransaction(
      id: id,
      userId: userId,
      transactionType: _mapTransactionType(transactionType),
      amount: amount.toDouble(),
      status: status,
      createdAt: createdAt,
      metadata: metadata,
      title: title,
      subtitle: subtitle,
      iconUrl: iconUrl,
    );
  }

  WalletTransactionType _mapTransactionType(String type) {
    switch (type.toUpperCase()) {
      case 'CAMPAIGN_DONATION':
        return WalletTransactionType.campaignDonation;
      case 'GIFT':
        return WalletTransactionType.gift;
      default:
        return WalletTransactionType.unknown;
    }
  }
}
