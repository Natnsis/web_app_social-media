import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/live_streaming/data/datasources/live_stream_remote_datasource.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream.dart';
import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/live_stream_repository.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';

class LiveStreamRepositoryImpl implements LiveStreamRepository {
  final LiveStreamRemoteDataSource remoteDataSource;

  LiveStreamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LiveStream>>> getLiveStreams() async {
    try {
      final streams = await remoteDataSource.getLiveStreams();
      return Right(streams.map((stream) => stream.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LiveStream>> getStreamById(String id) async {
    try {
      final stream = await remoteDataSource.getStreamById(id);
      return Right(stream.toEntity());
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LiveStreamChatMessage>>> getStreamChat(
    String streamId,
  ) async {
    try {
      final messages = await remoteDataSource.getStreamChat(streamId);
      return Right(messages.map((message) => message.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, LiveStreamChatMessage>> watchStreamChat(String streamId) {
    return remoteDataSource.watchStreamChat(streamId).map(
      (model) => Right<Failure, LiveStreamChatMessage>(model.toEntity()),
    ).handleError((e) => Left<Failure, LiveStreamChatMessage>(ServerFailure(message: e.toString())));
  }

  @override
  Future<Either<Failure, LiveStreamChatMessage>> sendStreamChat({
    required String streamId,
    required String content,
    required String senderName,
    String? senderAvatarUrl,
  }) async {
    try {
      final message = await remoteDataSource.sendStreamChat(
        streamId: streamId,
        content: content,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
      );
      return Right(message.toEntity());
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getViewerComposerAvatarUrl() async {
    try {
      return Right(remoteDataSource.getViewerComposerAvatarUrl());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LiveStream>> createStream({
    required String title,
    String? description,
    String? startAt,
    String? endAt,
  }) async {
    try {
      final stream = await remoteDataSource.createStream(
        title: title,
        description: description,
        startAt: startAt,
        endAt: endAt,
      );
      return Right(stream);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LiveStream>> publishStream(String id) async {
    try {
      final stream = await remoteDataSource.publishStream(id);
      return Right(stream);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endStream(String id) async {
    try {
      await remoteDataSource.endStream(id);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
