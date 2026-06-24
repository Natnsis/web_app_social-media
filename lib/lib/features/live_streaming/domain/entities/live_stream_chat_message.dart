import 'package:equatable/equatable.dart';

class LiveStreamChatMessage extends Equatable {
  final String id;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final DateTime createdAt;

  const LiveStreamChatMessage({
    required this.id,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, senderName, senderAvatarUrl, content, createdAt];
}
