import 'package:equatable/equatable.dart';

/// Quoted parent message shown inside a reply bubble.
class ChatMessageReplyPreview extends Equatable {
  final String messageId;
  final String senderName;
  final String content;
  final bool isOriginalMine;

  /// Network URL of an image/video attached to the original message.
  /// When set, the reply quote strip shows a small thumbnail on the right.
  final String? mediaUrl;

  const ChatMessageReplyPreview({
    required this.messageId,
    required this.senderName,
    required this.content,
    required this.isOriginalMine,
    this.mediaUrl,
  });

  @override
  List<Object?> get props => [messageId, senderName, content, isOriginalMine, mediaUrl];
}
