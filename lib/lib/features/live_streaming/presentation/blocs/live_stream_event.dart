import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';

sealed class LiveStreamEvent extends Equatable {
  const LiveStreamEvent();

  @override
  List<Object?> get props => [];
}

final class LiveStreamsRequested extends LiveStreamEvent {
  const LiveStreamsRequested();
}

final class LiveStreamsRefreshed extends LiveStreamEvent {
  const LiveStreamsRefreshed();
}

final class LiveStreamDetailRequested extends LiveStreamEvent {
  final String streamId;

  const LiveStreamDetailRequested(this.streamId);

  @override
  List<Object?> get props => [streamId];
}

final class GoLiveRequested extends LiveStreamEvent {
  final String title;
  final String? description;
  final String? startAt;
  final String? endAt;

  const GoLiveRequested({
    required this.title,
    this.description,
    this.startAt,
    this.endAt,
  });

  @override
  List<Object?> get props => [title, description, startAt, endAt];
}

class PublishLiveStreamRequested extends LiveStreamEvent {
  final String streamId;

  const PublishLiveStreamRequested(this.streamId);

  @override
  List<Object?> get props => [streamId];
}

final class EndLiveStreamRequested extends LiveStreamEvent {
  final String streamId;

  const EndLiveStreamRequested(this.streamId);

  @override
  List<Object?> get props => [streamId];
}

final class LiveStreamChatMessageSent extends LiveStreamEvent {
  final String streamId;
  final String message;

  const LiveStreamChatMessageSent({
    required this.streamId,
    required this.message,
  });

  @override
  List<Object?> get props => [streamId, message];
}

final class LiveStreamChatUpdated extends LiveStreamEvent {
  final LiveStreamChatMessage message;

  const LiveStreamChatUpdated(this.message);

  @override
  List<Object?> get props => [message];
}
