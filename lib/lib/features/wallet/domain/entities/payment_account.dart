import 'package:equatable/equatable.dart';

class PaymentAccount extends Equatable {
  final String id;
  final String churchId;
  final String provider;
  final String accountName;
  final String accountNumber;
  final String providerAccountId;
  final bool isVerified;
  final bool isActive;

  const PaymentAccount({
    required this.id,
    required this.churchId,
    required this.provider,
    required this.accountName,
    required this.accountNumber,
    required this.providerAccountId,
    required this.isVerified,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        churchId,
        provider,
        accountName,
        accountNumber,
        providerAccountId,
        isVerified,
        isActive,
      ];
}
