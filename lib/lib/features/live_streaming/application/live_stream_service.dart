import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/live_stream_repository.dart';

class LiveStreamService {
  final LiveStreamRepository _repository;

  LiveStreamService(this._repository);

  Future<Either<Failure, List<LiveStream>>> getLiveStreams() =>
      _repository.getLiveStreams();

  Future<Either<Failure, LiveStream>> getStreamById(String id) =>
      _repository.getStreamById(id);

  Future<Either<Failure, List<LiveStreamChatMessage>>> getStreamChat(
    String streamId,
  ) =>
      _repository.getStreamChat(streamId);

  Stream<Either<Failure, LiveStreamChatMessage>> watchStreamChat(String streamId) =>
      _repository.watchStreamChat(streamId);

  Future<Either<Failure, LiveStreamChatMessage>> sendStreamChat({
    required String streamId,
    required String content,
    required String senderName,
    String? senderAvatarUrl,
  }) {
    return _repository.sendStreamChat(
      streamId: streamId,
      content: content,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
    );
  }

  Future<Either<Failure, String>> getViewerComposerAvatarUrl() =>
      _repository.getViewerComposerAvatarUrl();

  Future<Either<Failure, LiveStream>> createStream({
    required String title,
    String? description,
    String? startAt,
    String? endAt,
  }) {
    return _repository.createStream(
      title: title,
      description: description,
      startAt: startAt,
      endAt: endAt,
    );
  }

  Future<Either<Failure, LiveStream>> publishStream(String id) {
    return _repository.publishStream(id);
  }

  Future<Either<Failure, void>> endStream(String id) =>
      _repository.endStream(id);
}
