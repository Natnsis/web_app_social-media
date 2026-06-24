import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_period.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';

sealed class SubscribersState extends Equatable {
  const SubscribersState();

  @override
  List<Object?> get props => [];
}

final class SubscribersInitial extends SubscribersState {
  const SubscribersInitial();
}

final class SubscribersLoading extends SubscribersState {
  final GiftPeriod period;

  const SubscribersLoading({this.period = GiftPeriod.month});

  @override
  List<Object?> get props => [period];
}

final class SubscribersLoaded extends SubscribersState {
  final SubscribersSummary summary;

  const SubscribersLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

final class SubscribersFailure extends SubscribersState {
  final String message;

  const SubscribersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
