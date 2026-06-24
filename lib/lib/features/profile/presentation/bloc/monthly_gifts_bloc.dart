import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/profile/application/profile_service.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/presentation/bloc/monthly_gifts_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/monthly_gifts_state.dart';

class MonthlyGiftsBloc extends Bloc<MonthlyGiftsEvent, MonthlyGiftsState> {
  final ProfileService _profileService;

  MonthlyGiftsBloc({required ProfileService profileService})
      : _profileService = profileService,
        super(const MonthlyGiftsInitial()) {
    on<MonthlyGiftsRequested>(_onRequested);
    on<MonthlyGiftsPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onRequested(
    MonthlyGiftsRequested event,
    Emitter<MonthlyGiftsState> emit,
  ) async {
    await _load(GiftPeriod.month, emit);
  }

  Future<void> _onPeriodChanged(
    MonthlyGiftsPeriodChanged event,
    Emitter<MonthlyGiftsState> emit,
  ) async {
    await _load(event.period, emit);
  }

  Future<void> _load(GiftPeriod period, Emitter<MonthlyGiftsState> emit) async {
    emit(MonthlyGiftsLoading(period: period));
    final result = await _profileService.getGiftSummary(period);
    result.fold(
      (failure) => emit(MonthlyGiftsFailure(failure.message)),
      (summary) => emit(MonthlyGiftsLoaded(summary)),
    );
  }
}
