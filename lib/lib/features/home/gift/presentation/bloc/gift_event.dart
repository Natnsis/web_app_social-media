import 'package:equatable/equatable.dart';

sealed class GiftEvent extends Equatable {
  const GiftEvent();

  @override
  List<Object?> get props => [];
}

final class GiftHubRequested extends GiftEvent {
  const GiftHubRequested();
}

final class GiftHubRefreshed extends GiftEvent {
  const GiftHubRefreshed();
}

final class LiveGiftSent extends GiftEvent {
  final String streamId;
  final String giftItemId;

  const LiveGiftSent({
    required this.streamId,
    required this.giftItemId,
  });

  @override
  List<Object?> get props => [streamId, giftItemId];
}

final class SendGiftRequested extends GiftEvent {
  final String giftCatalogId;
  final String recipientChurchId;
  final int quantity;
  final String message;

  const SendGiftRequested({
    required this.giftCatalogId,
    required this.recipientChurchId,
    required this.quantity,
    required this.message,
  });

  @override
  List<Object?> get props => [giftCatalogId, recipientChurchId, quantity, message];
}

final class GiftFeedbackDismissed extends GiftEvent {
  const GiftFeedbackDismissed();
}

final class GiftTransactionStatusChecked extends GiftEvent {
  final String txRef;

  const GiftTransactionStatusChecked(this.txRef);

  @override
  List<Object?> get props => [txRef];
}
