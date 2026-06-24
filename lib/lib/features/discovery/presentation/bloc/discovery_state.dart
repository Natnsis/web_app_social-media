import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_content.dart';

sealed class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

final class DiscoveryInitial extends DiscoveryState {
  const DiscoveryInitial();
}

final class DiscoveryLoading extends DiscoveryState {
  const DiscoveryLoading();
}

final class DiscoveryLoaded extends DiscoveryState {
  final DiscoveryContent content;

  const DiscoveryLoaded(this.content);

  DiscoveryLoaded copyWith({DiscoveryContent? content}) {
    return DiscoveryLoaded(content ?? this.content);
  }

  @override
  List<Object?> get props => [content];
}

final class DiscoveryFailure extends DiscoveryState {
  final String message;

  const DiscoveryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
