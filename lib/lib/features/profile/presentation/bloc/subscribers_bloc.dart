import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/profile/application/profile_service.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/presentation/bloc/subscribers_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/subscribers_state.dart';

class SubscribersBloc extends Bloc<SubscribersEvent, SubscribersState> {
  final ProfileService _profileService;

  SubscribersBloc({required ProfileService profileService})
      : _profileService = profileService,
        super(const SubscribersInitial()) {
    on<SubscribersRequested>(_onRequested);
    on<SubscribersPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onRequested(
    SubscribersRequested event,
    Emitter<SubscribersState> emit,
  ) async {
    await _load(GiftPeriod.month, emit);
  }

  Future<void> _onPeriodChanged(
    SubscribersPeriodChanged event,
    Emitter<SubscribersState> emit,
  ) async {
    await _load(event.period, emit);
  }

  Future<void> _load(GiftPeriod period, Emitter<SubscribersState> emit) async {
    emit(SubscribersLoading(period: period));
    final result = await _profileService.getSubscribersSummary(period);
    result.fold(
      (failure) => emit(SubscribersFailure(failure.message)),
      (summary) => emit(SubscribersLoaded(summary)),
    );
  }
}
