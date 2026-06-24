import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';

abstract class LiveStreamRepository {
  Future<Either<Failure, List<LiveStream>>> getLiveStreams();

  Future<Either<Failure, LiveStream>> getStreamById(String id);

  Future<Either<Failure, List<LiveStreamChatMessage>>> getStreamChat(
    String streamId,
  );

  Stream<Either<Failure, LiveStreamChatMessage>> watchStreamChat(String streamId);


  Future<Either<Failure, LiveStreamChatMessage>> sendStreamChat({
    required String streamId,
    required String content,
    required String senderName,
    String? senderAvatarUrl,
  });

  Future<Either<Failure, String>> getViewerComposerAvatarUrl();

  Future<Either<Failure, LiveStream>> createStream({
    required String title,
    String? description,
    String? startAt,
    String? endAt,
  });

  Future<Either<Failure, LiveStream>> publishStream(String id);

  Future<Either<Failure, void>> endStream(String id);
}
