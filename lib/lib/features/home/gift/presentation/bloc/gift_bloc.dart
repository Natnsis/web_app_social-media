import 'package:faithconnect/features/home/gift/application/gift_service.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_hub_content.dart';
import 'package:faithconnect/features/home/gift/data/dto/send_gift_dto.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_event.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GiftBloc extends Bloc<GiftEvent, GiftState> {
  final GiftService _giftService;

  GiftBloc({required GiftService giftService})
      : _giftService = giftService,
        super(const GiftInitial()) {
    on<GiftHubRequested>(_onRequested);
    on<GiftHubRefreshed>(_onRefreshed);
    on<LiveGiftSent>(_onLiveGiftSent);
    on<SendGiftRequested>(_onSendGiftRequested);
    on<GiftFeedbackDismissed>(_onFeedbackDismissed);
    on<GiftTransactionStatusChecked>(_onTransactionStatusChecked);
  }

  Future<void> _onRequested(
    GiftHubRequested event,
    Emitter<GiftState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRefreshed(
    GiftHubRefreshed event,
    Emitter<GiftState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onLiveGiftSent(
    LiveGiftSent event,
    Emitter<GiftState> emit,
  ) async {
    final current = state;
    if (current is! GiftLoaded) return;

    emit(current.copyWith(isSendingGift: true, clearFeedback: true));

    final result = await _giftService.sendLiveGift(
      streamId: event.streamId,
      giftItemId: event.giftItemId,
    );

    result.fold(
      (failure) => emit(
        current.copyWith(
          isSendingGift: false,
          feedbackMessage: failure.message,
          feedbackIsError: true,
        ),
      ),
      (receipt) {
        final updatedHub = GiftHubContent(
          title: current.content.title,
          catalog: receipt.updatedCatalog,
        );
        emit(
          GiftLoaded(
            content: updatedHub,
            feedbackMessage: 'Sent ${receipt.gift.name}',
            feedbackIsError: false,
          ),
        );
      },
    );
  }

  Future<void> _onSendGiftRequested(
    SendGiftRequested event,
    Emitter<GiftState> emit,
  ) async {
    final current = state;
    if (current is! GiftLoaded) return;

    emit(current.copyWith(isSendingGift: true, clearFeedback: true, clearCheckoutUrl: true));

    final result = await _giftService.sendGift(
      SendGiftDto(
        giftCatalogId: event.giftCatalogId,
        recipientChurchId: event.recipientChurchId,
        quantity: event.quantity,
        message: event.message,
      ),
    );

    result.fold(
      (failure) => emit(
        current.copyWith(
          isSendingGift: false,
          feedbackMessage: failure.message,
          feedbackIsError: true,
        ),
      ),
      (checkoutInfo) {
        emit(
          current.copyWith(
            isSendingGift: false,
            checkoutUrl: checkoutInfo.checkoutUrl,
            txRef: checkoutInfo.txRef,
          ),
        );
      },
    );
  }

  void _onFeedbackDismissed(
    GiftFeedbackDismissed event,
    Emitter<GiftState> emit,
  ) {
    final current = state;
    if (current is GiftLoaded) {
      emit(current.copyWith(clearFeedback: true, clearCheckoutUrl: true));
    }
  }

  Future<void> _onTransactionStatusChecked(
    GiftTransactionStatusChecked event,
    Emitter<GiftState> emit,
  ) async {
    final current = state;
    if (current is! GiftLoaded) return;

    emit(current.copyWith(isSendingGift: true, clearFeedback: true));

    final result = await _giftService.checkTransactionStatus(event.txRef);

    result.fold(
      (failure) => emit(
        current.copyWith(
          isSendingGift: false,
          feedbackMessage: failure.message,
          feedbackIsError: true,
        ),
      ),
      (statusStr) => emit(
        current.copyWith(
          isSendingGift: false,
          feedbackMessage: statusStr,
          feedbackIsError: false,
          clearCheckoutUrl: true,
        ),
      ),
    );
  }

  Future<void> _load(Emitter<GiftState> emit) async {
    emit(const GiftLoading());
    final result = await _giftService.getHubContent();
    result.fold(
      (failure) => emit(GiftFailure(failure.message)),
      (content) => emit(GiftLoaded(content: content)),
    );
  }
}
