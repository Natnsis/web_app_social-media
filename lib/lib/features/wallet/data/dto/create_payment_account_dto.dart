class CreatePaymentAccountDto {
  final String provider;
  final String accountName;
  final String accountNumber;
  final String? providerAccountId;

  CreatePaymentAccountDto({
    required this.provider,
    required this.accountName,
    required this.accountNumber,
    this.providerAccountId,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'accountName': accountName,
      'accountNumber': accountNumber,
      if (providerAccountId != null && providerAccountId!.isNotEmpty)
        'providerAccountId': providerAccountId,
    };
  }
}
