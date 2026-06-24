import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/features/live_streaming/data/models/live_stream_chat_message_model.dart';
import 'package:faithconnect/features/live_streaming/data/models/live_stream_model.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';

abstract class LiveStreamRemoteDataSource {
  Future<List<LiveStreamModel>> getLiveStreams();

  Future<LiveStreamModel> getStreamById(String id);

  Future<List<LiveStreamChatMessageModel>> getStreamChat(String streamId);

  Stream<LiveStreamChatMessageModel> watchStreamChat(String streamId);

  Future<LiveStreamChatMessageModel> sendStreamChat({
    required String streamId,
    required String content,
    required String senderName,
    String? senderAvatarUrl,
  });

  String getViewerComposerAvatarUrl();

  Future<LiveStreamModel> createStream({
    required String title,
    String? description,
    String? startAt,
    String? endAt,
  });

  Future<LiveStreamModel> publishStream(String id);

  Future<void> endStream(String id);
}

class LiveStreamRemoteDataSourceImpl implements LiveStreamRemoteDataSource {
  final Dio dio;

  LiveStreamRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LiveStreamModel>> getLiveStreams() async {
    try {
      final response = await dio.get(LiveStreamApiEndpoint.list);
      if (response.statusCode == 200) {
        final dynamic rawData = response.data['data'] ?? response.data;
        List<dynamic> list = [];
        
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map) {
          if (rawData.containsKey('data') && rawData['data'] is List) {
            list = rawData['data'] as List;
          } else if (rawData.containsKey('items') && rawData['items'] is List) {
            list = rawData['items'] as List;
          } else {
            list = [rawData];
          }
        }
        
        return list.map((e) => LiveStreamModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw const AuthException('Failed to load livestreams');
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<LiveStreamModel> getStreamById(String id) async {
    try {
      final response = await dio.get(LiveStreamApiEndpoint.detail(id));
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return LiveStreamModel.fromJson(data);
      }
      throw const AuthException('Failed to load stream details');
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<List<LiveStreamChatMessageModel>> getStreamChat(
    String streamId,
  ) async {
    try {
      final response = await dio.get('${LiveStreamApiEndpoint.detail(streamId)}/chat');
      if (response.statusCode == 200) {
        final dynamic rawData = response.data['data'] ?? response.data;
        List<dynamic> list = [];
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map) {
          if (rawData.containsKey('data') && rawData['data'] is List) {
            list = rawData['data'] as List;
          } else if (rawData.containsKey('items') && rawData['items'] is List) {
            list = rawData['items'] as List;
          } else {
            list = [rawData];
          }
        }
        return list.map((e) => LiveStreamChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Stream<LiveStreamChatMessageModel> watchStreamChat(String streamId) {
    // To be implemented with a real socket later
    return const Stream.empty();
  }

  @override
  Future<LiveStreamChatMessageModel> sendStreamChat({
    required String streamId,
    required String content,
    required String senderName,
    String? senderAvatarUrl,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return LiveStreamChatMessageModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
  }

  @override
  String getViewerComposerAvatarUrl() => '';

  @override
  Future<LiveStreamModel> createStream({
    required String title,
    String? description,
    String? startAt,
    String? endAt,
  }) async {
    if (title.trim().isEmpty) {
      throw const AuthException('Stream title is required');
    }

    try {
      final data = <String, dynamic>{
        'title': title.trim(),
      };
      if (description != null) data['description'] = description.trim();
      if (startAt != null) data['startAt'] = startAt;
      if (endAt != null) data['endAt'] = endAt;

      final response = await dio.post(LiveStreamApiEndpoint.list, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data['data'] ?? response.data;
        return LiveStreamModel.fromJson(result is List ? result.first : result);
      }
      throw const AuthException('Failed to create livestream');
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<LiveStreamModel> publishStream(String id) async {
    try {
      final publishResponse = await dio.post<dynamic>(
        LiveStreamApiEndpoint.publish(id),
      );
      
      if (publishResponse.statusCode == 200 || publishResponse.statusCode == 201) {
        final publishResult = publishResponse.data['data'] ?? publishResponse.data;
        return LiveStreamModel.fromJson(publishResult is List ? publishResult.first : publishResult);
      }
      throw const AuthException('Failed to publish livestream');
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> endStream(String id) async {
    try {
      await dio.delete<void>(
        LiveStreamApiEndpoint.detail(id),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }
}
