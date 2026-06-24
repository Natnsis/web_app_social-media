import 'package:equatable/equatable.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';

sealed class LiveStreamState extends Equatable {
  const LiveStreamState();

  @override
  List<Object?> get props => [];
}

final class LiveStreamInitial extends LiveStreamState {
  const LiveStreamInitial();
}

final class LiveStreamLoading extends LiveStreamState {
  const LiveStreamLoading();
}

final class LiveStreamsLoaded extends LiveStreamState {
  final List<LiveStream> streams;

  const LiveStreamsLoaded(this.streams);

  @override
  List<Object?> get props => [streams];
}

final class LiveStreamWatchLoaded extends LiveStreamState {
  final LiveStream stream;
  final List<LiveStreamChatMessage> chatMessages;
  final String viewerAvatarUrl;
  final bool isSendingChat;

  const LiveStreamWatchLoaded({
    required this.stream,
    required this.chatMessages,
    required this.viewerAvatarUrl,
    this.isSendingChat = false,
  });

  LiveStreamWatchLoaded copyWith({
    LiveStream? stream,
    List<LiveStreamChatMessage>? chatMessages,
    String? viewerAvatarUrl,
    bool? isSendingChat,
  }) {
    return LiveStreamWatchLoaded(
      stream: stream ?? this.stream,
      chatMessages: chatMessages ?? this.chatMessages,
      viewerAvatarUrl: viewerAvatarUrl ?? this.viewerAvatarUrl,
      isSendingChat: isSendingChat ?? this.isSendingChat,
    );
  }

  @override
  List<Object?> get props =>
      [stream, chatMessages, viewerAvatarUrl, isSendingChat];
}

final class GoLiveInProgress extends LiveStreamState {
  const GoLiveInProgress();
}

class GoLiveCreated extends LiveStreamState {
  final LiveStream stream;

  const GoLiveCreated(this.stream);

  @override
  List<Object?> get props => [stream];
}

final class GoLiveSuccess extends LiveStreamState {
  final LiveStream stream;

  const GoLiveSuccess(this.stream);

  @override
  List<Object?> get props => [stream];
}

final class LiveStreamEnded extends LiveStreamState {
  const LiveStreamEnded();
}

final class LiveStreamFailure extends LiveStreamState {
  final String message;

  const LiveStreamFailure(this.message);

  @override
  List<Object?> get props => [message];
}
