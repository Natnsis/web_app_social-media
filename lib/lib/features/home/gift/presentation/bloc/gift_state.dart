import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_hub_content.dart';

sealed class GiftState extends Equatable {
  const GiftState();

  @override
  List<Object?> get props => [];
}

final class GiftInitial extends GiftState {
  const GiftInitial();
}

final class GiftLoading extends GiftState {
  const GiftLoading();
}

final class GiftLoaded extends GiftState {
  final GiftHubContent content;
  final bool isSendingGift;
  final String? feedbackMessage;
  final bool feedbackIsError;
  final String? checkoutUrl;
  final String? txRef;

  const GiftLoaded({
    required this.content,
    this.isSendingGift = false,
    this.feedbackMessage,
    this.feedbackIsError = false,
    this.checkoutUrl,
    this.txRef,
  });

  GiftLoaded copyWith({
    GiftHubContent? content,
    bool? isSendingGift,
    String? feedbackMessage,
    bool? feedbackIsError,
    String? checkoutUrl,
    String? txRef,
    bool clearFeedback = false,
    bool clearCheckoutUrl = false,
  }) {
    return GiftLoaded(
      content: content ?? this.content,
      isSendingGift: isSendingGift ?? this.isSendingGift,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
      checkoutUrl: clearCheckoutUrl ? null : (checkoutUrl ?? this.checkoutUrl),
      txRef: clearCheckoutUrl ? null : (txRef ?? this.txRef),
    );
  }

  @override
  List<Object?> get props => [
        content,
        isSendingGift,
        feedbackMessage,
        feedbackIsError,
        checkoutUrl,
        txRef,
      ];
}

final class GiftFailure extends GiftState {
  final String message;

  const GiftFailure(this.message);

  @override
  List<Object?> get props => [message];
}
