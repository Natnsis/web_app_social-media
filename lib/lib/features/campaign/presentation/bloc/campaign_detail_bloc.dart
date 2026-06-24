import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/campaign/application/campaign_service.dart';
import 'package:faithconnect/features/campaign/data/dto/donate_campaign_dto.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaign_detail_event.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaign_detail_state.dart';
import 'package:faithconnect/core/network/payment_checkout_info.dart';

class CampaignDetailBloc extends Bloc<CampaignDetailEvent, CampaignDetailState> {
  final CampaignService _campaignService;
  final String campaignId;

  CampaignDetailBloc({
    required CampaignService campaignService,
    required this.campaignId,
  })  : _campaignService = campaignService,
        super(const CampaignDetailInitial()) {
    on<CampaignDetailRequested>(_onRequested);
    on<CampaignDonateRequested>(_onDonateRequested);
    on<CampaignFeedbackDismissed>(_onFeedbackDismissed);
    on<TransactionStatusChecked>(_onTransactionStatusChecked);
  }

  Future<void> _onRequested(
    CampaignDetailRequested event,
    Emitter<CampaignDetailState> emit,
  ) async {
    emit(const CampaignDetailLoading());
    final result = await _campaignService.getCampaignDetail(campaignId);
    result.fold(
      (failure) => emit(CampaignDetailFailure(failure.message)),
      (detail) => emit(CampaignDetailLoaded(detail: detail)),
    );
  }

  Future<void> _onDonateRequested(
    CampaignDonateRequested event,
    Emitter<CampaignDetailState> emit,
  ) async {
    final current = state;
    if (current is! CampaignDetailLoaded) return;

    emit(current.copyWith(isDonating: true, clearFeedback: true, clearCheckoutUrl: true));

    final result = await _campaignService.donateToCampaign(
      campaignId: campaignId,
      dto: DonateCampaignDto(
        amountEtb: event.amountEtb,
        donorMessage: event.donorMessage,
      ),
    );

    result.fold(
      (failure) => emit(
        current.copyWith(
          isDonating: false,
          feedbackMessage: failure.message,
          feedbackIsError: true,
        ),
      ),
      (PaymentCheckoutInfo checkoutInfo) {
        emit(
          current.copyWith(
            isDonating: false,
            checkoutUrl: checkoutInfo.checkoutUrl,
            txRef: checkoutInfo.txRef,
          ),
        );
      },
    );
  }

  void _onFeedbackDismissed(
    CampaignFeedbackDismissed event,
    Emitter<CampaignDetailState> emit,
  ) {
    final current = state;
    if (current is CampaignDetailLoaded) {
      emit(current.copyWith(clearFeedback: true, clearCheckoutUrl: true));
    }
  }

  Future<void> _onTransactionStatusChecked(
    TransactionStatusChecked event,
    Emitter<CampaignDetailState> emit,
  ) async {
    final current = state;
    if (current is! CampaignDetailLoaded) return;

    emit(current.copyWith(isDonating: true, clearFeedback: true));

    final result = await _campaignService.checkTransactionStatus(event.txRef);

    result.fold(
      (failure) => emit(
        current.copyWith(
          isDonating: false,
          feedbackMessage: failure.message,
          feedbackIsError: true,
        ),
      ),
      (statusStr) => emit(
        current.copyWith(
          isDonating: false,
          feedbackMessage: statusStr,
          feedbackIsError: false,
          clearCheckoutUrl: true,
        ),
      ),
    );
  }
}
