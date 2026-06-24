import 'package:faithconnect/features/live_streaming/domain/entities/live_stream_chat_message.dart';

class LiveStreamChatMessageModel extends LiveStreamChatMessage {
  const LiveStreamChatMessageModel({
    required super.id,
    required super.senderName,
    super.senderAvatarUrl,
    required super.content,
    required super.createdAt,
  });

  factory LiveStreamChatMessageModel.fromEntity(LiveStreamChatMessage entity) {
    return LiveStreamChatMessageModel(
      id: entity.id,
      senderName: entity.senderName,
      senderAvatarUrl: entity.senderAvatarUrl,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }

  factory LiveStreamChatMessageModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamChatMessageModel(
      id: json['id'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'Unknown',
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  LiveStreamChatMessage toEntity() => LiveStreamChatMessage(
        id: id,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
        content: content,
        createdAt: createdAt,
      );
}
