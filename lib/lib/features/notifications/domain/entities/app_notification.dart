import 'package:equatable/equatable.dart';

enum NotificationCategory {
  like,
  comment,
  follow,
  live,
  campaign,
  mention,
  system,
  message,
}

enum NotificationFilter {
  all,
  unread,
}

class AppNotification extends Equatable {
  final String id;
  final NotificationCategory category;
  final String actorName;
  final String? actorAvatarUrl;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? previewImageUrl;
  final String? targetId;

  const AppNotification({
    required this.id,
    required this.category,
    required this.actorName,
    this.actorAvatarUrl,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.previewImageUrl,
    this.targetId,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      category: category,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      previewImageUrl: previewImageUrl,
      targetId: targetId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        actorName,
        actorAvatarUrl,
        title,
        body,
        createdAt,
        isRead,
        previewImageUrl,
        targetId,
      ];
}
