import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';

sealed class MonthlyGiftsEvent extends Equatable {
  const MonthlyGiftsEvent();

  @override
  List<Object?> get props => [];
}

final class MonthlyGiftsRequested extends MonthlyGiftsEvent {
  const MonthlyGiftsRequested();
}

final class MonthlyGiftsPeriodChanged extends MonthlyGiftsEvent {
  final GiftPeriod period;

  const MonthlyGiftsPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}
