import 'package:faithconnect/features/notifications/domain/entities/app_notification.dart';

class NotificationApiDto {
  final String id;
  final String category;
  final String actorName;
  final String? actorAvatarUrl;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? previewImageUrl;
  final String? targetId;

  NotificationApiDto({
    required this.id,
    required this.category,
    required this.actorName,
    this.actorAvatarUrl,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.previewImageUrl,
    this.targetId,
  });

  factory NotificationApiDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'SYSTEM';
    
    final data = json['data'] as Map<String, dynamic>?;
    String? targetId = data?['conversationId'] as String? ?? 
                       data?['postId'] as String? ?? 
                       data?['shortId'] as String?;

    String actorName = json['actorName'] as String? ?? '';
    String bodyText = json['body'] as String? ?? '';
    
    if (type == 'NEW_MESSAGE' && bodyText.contains(':')) {
       final split = bodyText.split(':');
       actorName = split.first.trim();
       bodyText = split.skip(1).join(':').trim();
    }

    return NotificationApiDto(
      id: json['id'] as String? ?? '',
      category: type,
      actorName: actorName,
      actorAvatarUrl: json['actorAvatarUrl'] as String?,
      title: json['title'] as String? ?? '',
      body: bodyText,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      previewImageUrl: json['previewImageUrl'] as String?,
      targetId: targetId,
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      category: _parseCategory(category),
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead,
      previewImageUrl: previewImageUrl,
      targetId: targetId,
    );
  }

  NotificationCategory _parseCategory(String cat) {
    switch (cat.toUpperCase()) {
      case 'LIKE':
        return NotificationCategory.like;
      case 'COMMENT':
        return NotificationCategory.comment;
      case 'FOLLOW':
        return NotificationCategory.follow;
      case 'LIVE':
        return NotificationCategory.live;
      case 'CAMPAIGN':
        return NotificationCategory.campaign;
      case 'MENTION':
        return NotificationCategory.mention;
      case 'NEW_MESSAGE':
        return NotificationCategory.message;
      case 'SYSTEM':
      default:
        return NotificationCategory.system;
    }
  }
}
