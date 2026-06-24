import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/live_streaming/application/live_stream_service.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_event.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_state.dart';

class LiveStreamBloc extends Bloc<LiveStreamEvent, LiveStreamState> {
  final LiveStreamService _liveStreamService;
  StreamSubscription? _chatSubscription;

  LiveStreamBloc({required LiveStreamService liveStreamService})
      : _liveStreamService = liveStreamService,
        super(const LiveStreamInitial()) {
    on<LiveStreamsRequested>(_onStreamsRequested);
    on<LiveStreamsRefreshed>(_onStreamsRequested);
    on<LiveStreamDetailRequested>(_onDetailRequested);
    on<LiveStreamChatUpdated>(_onChatUpdated);
    on<LiveStreamChatMessageSent>(_onChatMessageSent);
    on<GoLiveRequested>(_onGoLiveRequested);
    on<PublishLiveStreamRequested>(_onPublishLiveStreamRequested);
    on<EndLiveStreamRequested>(_onEndStreamRequested);
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStreamsRequested(
    LiveStreamEvent event,
    Emitter<LiveStreamState> emit,
  ) async {
    emit(const LiveStreamLoading());
    final result = await _liveStreamService.getLiveStreams();
    result.fold(
      (failure) => emit(LiveStreamFailure(failure.message)),
      (streams) => emit(LiveStreamsLoaded(streams)),
    );
  }

  Future<void> _onDetailRequested(
    LiveStreamDetailRequested event,
    Emitter<LiveStreamState> emit,
  ) async {
    emit(const LiveStreamLoading());
    final streamResult =
        await _liveStreamService.getStreamById(event.streamId);

    await streamResult.fold(
      (failure) async => emit(LiveStreamFailure(failure.message)),
      (stream) async {
        final chatResult =
            await _liveStreamService.getStreamChat(event.streamId);
        final avatarResult =
            await _liveStreamService.getViewerComposerAvatarUrl();

        chatResult.fold(
          (failure) => emit(LiveStreamFailure(failure.message)),
          (messages) {
            emit(
              LiveStreamWatchLoaded(
                stream: stream,
                chatMessages: messages,
                viewerAvatarUrl: avatarResult.getOrElse(() => ''),
              ),
            );

            // Subscribe to real-time chat updates
            _chatSubscription?.cancel();
            _chatSubscription = _liveStreamService
                .watchStreamChat(event.streamId)
                .listen((result) {
              result.fold(
                (failure) => null, // Optionally handle failure
                (message) {
                  if (!isClosed) {
                    add(LiveStreamChatUpdated(message));
                  }
                },
              );
            });
          },
        );
      },
    );
  }

  void _onChatUpdated(
    LiveStreamChatUpdated event,
    Emitter<LiveStreamState> emit,
  ) {
    final current = state;
    if (current is LiveStreamWatchLoaded) {
      emit(
        current.copyWith(
          chatMessages: [...current.chatMessages, event.message],
        ),
      );
    }
  }

  Future<void> _onChatMessageSent(
    LiveStreamChatMessageSent event,
    Emitter<LiveStreamState> emit,
  ) async {
    final current = state;
    if (current is! LiveStreamWatchLoaded) return;

    final trimmed = event.message.trim();
    if (trimmed.isEmpty) return;

    emit(current.copyWith(isSendingChat: true));

    final result = await _liveStreamService.sendStreamChat(
      streamId: event.streamId,
      content: trimmed,
      senderName: 'You',
      senderAvatarUrl: current.viewerAvatarUrl,
    );

    result.fold(
      (failure) => emit(current.copyWith(isSendingChat: false)),
      (message) => emit(
        current.copyWith(
          isSendingChat: false,
          chatMessages: [...current.chatMessages, message],
        ),
      ),
    );
  }

  Future<void> _onGoLiveRequested(
    GoLiveRequested event,
    Emitter<LiveStreamState> emit,
  ) async {
    emit(const GoLiveInProgress());
    final result = await _liveStreamService.createStream(
      title: event.title,
      description: event.description,
      startAt: event.startAt,
      endAt: event.endAt,
    );
    result.fold(
      (failure) => emit(LiveStreamFailure(failure.message)),
      (stream) => emit(GoLiveCreated(stream)),
    );
  }

  Future<void> _onPublishLiveStreamRequested(
    PublishLiveStreamRequested event,
    Emitter<LiveStreamState> emit,
  ) async {
    emit(const GoLiveInProgress());
    final result = await _liveStreamService.publishStream(event.streamId);
    
    result.fold(
      (failure) => emit(LiveStreamFailure(failure.message)),
      (stream) => emit(GoLiveSuccess(stream)),
    );
  }

  Future<void> _onEndStreamRequested(
    EndLiveStreamRequested event,
    Emitter<LiveStreamState> emit,
  ) async {
    emit(const LiveStreamLoading());
    final result = await _liveStreamService.endStream(event.streamId);
    result.fold(
      (failure) => emit(LiveStreamFailure(failure.message)),
      (_) => emit(const LiveStreamEnded()),
    );
  }
}
