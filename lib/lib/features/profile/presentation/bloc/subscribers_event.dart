import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';

sealed class SubscribersEvent extends Equatable {
  const SubscribersEvent();

  @override
  List<Object?> get props => [];
}

final class SubscribersRequested extends SubscribersEvent {
  const SubscribersRequested();
}

final class SubscribersPeriodChanged extends SubscribersEvent {
  final GiftPeriod period;

  const SubscribersPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}
