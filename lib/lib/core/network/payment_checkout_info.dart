class PaymentCheckoutInfo {
  final String paymentTransactionId;
  final String txRef;
  final String checkoutUrl;
  final double amountEtb;

  const PaymentCheckoutInfo({
    required this.paymentTransactionId,
    required this.txRef,
    required this.checkoutUrl,
    required this.amountEtb,
  });

  factory PaymentCheckoutInfo.fromJson(Map<String, dynamic> json) {
    return PaymentCheckoutInfo(
      paymentTransactionId: json['paymentTransactionId'] as String,
      txRef: json['txRef'] as String,
      checkoutUrl: json['checkoutUrl'] as String,
      amountEtb: (json['amountEtb'] as num).toDouble(),
    );
  }
}
