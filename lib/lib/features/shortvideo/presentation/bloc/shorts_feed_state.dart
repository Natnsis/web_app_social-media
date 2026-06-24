import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/short_video.dart';

sealed class ShortsFeedState extends Equatable {
  const ShortsFeedState();

  @override
  List<Object?> get props => [];
}

final class ShortsFeedInitial extends ShortsFeedState {
  const ShortsFeedInitial();
}

final class ShortsFeedLoading extends ShortsFeedState {
  const ShortsFeedLoading();
}

final class ShortsFeedLoaded extends ShortsFeedState {
  final List<ShortVideo> videos;
  final int currentIndex;

  const ShortsFeedLoaded({
    required this.videos,
    this.currentIndex = 0,
  });

  ShortsFeedLoaded copyWith({
    List<ShortVideo>? videos,
    int? currentIndex,
  }) {
    return ShortsFeedLoaded(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [videos, currentIndex];
}

final class ShortsFeedFailure extends ShortsFeedState {
  final String message;

  const ShortsFeedFailure(this.message);

  @override
  List<Object?> get props => [message];
}
