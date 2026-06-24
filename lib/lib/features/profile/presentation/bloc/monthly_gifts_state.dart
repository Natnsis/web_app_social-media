import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';

sealed class MonthlyGiftsState extends Equatable {
  const MonthlyGiftsState();

  @override
  List<Object?> get props => [];
}

final class MonthlyGiftsInitial extends MonthlyGiftsState {
  const MonthlyGiftsInitial();
}

final class MonthlyGiftsLoading extends MonthlyGiftsState {
  final GiftPeriod period;

  const MonthlyGiftsLoading({this.period = GiftPeriod.month});

  @override
  List<Object?> get props => [period];
}

final class MonthlyGiftsLoaded extends MonthlyGiftsState {
  final GiftSummary summary;

  const MonthlyGiftsLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

final class MonthlyGiftsFailure extends MonthlyGiftsState {
  final String message;

  const MonthlyGiftsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
