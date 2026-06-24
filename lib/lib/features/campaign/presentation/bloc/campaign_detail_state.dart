import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_detail.dart';

sealed class CampaignDetailState extends Equatable {
  const CampaignDetailState();

  @override
  List<Object?> get props => [];
}

final class CampaignDetailInitial extends CampaignDetailState {
  const CampaignDetailInitial();
}

final class CampaignDetailLoading extends CampaignDetailState {
  const CampaignDetailLoading();
}

final class CampaignDetailLoaded extends CampaignDetailState {
  final CampaignDetail detail;
  final bool isDonating;
  final String? checkoutUrl;
  final String? txRef;
  final String? feedbackMessage;
  final bool feedbackIsError;

  const CampaignDetailLoaded({
    required this.detail,
    this.isDonating = false,
    this.checkoutUrl,
    this.txRef,
    this.feedbackMessage,
    this.feedbackIsError = false,
  });

  CampaignDetailLoaded copyWith({
    CampaignDetail? detail,
    bool? isDonating,
    String? checkoutUrl,
    String? txRef,
    String? feedbackMessage,
    bool? feedbackIsError,
    bool clearFeedback = false,
    bool clearCheckoutUrl = false,
  }) {
    return CampaignDetailLoaded(
      detail: detail ?? this.detail,
      isDonating: isDonating ?? this.isDonating,
      checkoutUrl: clearCheckoutUrl ? null : (checkoutUrl ?? this.checkoutUrl),
      txRef: clearCheckoutUrl ? null : (txRef ?? this.txRef),
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
    );
  }

  @override
  List<Object?> get props => [
        detail,
        isDonating,
        checkoutUrl,
        txRef,
        feedbackMessage,
        feedbackIsError,
      ];
}



final class CampaignDetailFailure extends CampaignDetailState {
  final String message;

  const CampaignDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
