import 'package:faithconnect/features/wallet/domain/entities/payment_account.dart';

class PaymentAccountDto {
  final String id;
  final String churchId;
  final String provider;
  final String accountName;
  final String accountNumber;
  final String providerAccountId;
  final bool isVerified;
  final bool isActive;

  PaymentAccountDto({
    required this.id,
    required this.churchId,
    required this.provider,
    required this.accountName,
    required this.accountNumber,
    required this.providerAccountId,
    required this.isVerified,
    required this.isActive,
  });

  factory PaymentAccountDto.fromJson(Map<String, dynamic> json) {
    return PaymentAccountDto(
      id: json['id'] ?? '',
      churchId: json['churchId'] ?? '',
      provider: json['provider'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      providerAccountId: json['providerAccountId'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
    );
  }

  PaymentAccount toEntity() {
    return PaymentAccount(
      id: id,
      churchId: churchId,
      provider: provider,
      accountName: accountName,
      accountNumber: accountNumber,
      providerAccountId: providerAccountId,
      isVerified: isVerified,
      isActive: isActive,
    );
  }
}
