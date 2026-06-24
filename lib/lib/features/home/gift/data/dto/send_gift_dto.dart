class SendGiftDto {
  final String giftCatalogId;
  final String recipientChurchId;
  final int quantity;
  final String message;

  const SendGiftDto({
    required this.giftCatalogId,
    required this.recipientChurchId,
    required this.quantity,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'giftCatalogId': giftCatalogId,
      'recipientChurchId': recipientChurchId,
      'quantity': quantity,
      'message': message,
    };
  }
}
