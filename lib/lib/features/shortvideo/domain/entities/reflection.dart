import 'package:equatable/equatable.dart';

class Reflection extends Equatable {
  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final String text;
  final int likeCount;
  final DateTime createdAt;
  final List<Reflection> replies;
  final int replyCount;
  final bool isLiked;
  final bool isOwnedByMe;

  const Reflection({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl,
    required this.text,
    this.likeCount = 0,
    required this.createdAt,
    this.replies = const [],
    this.replyCount = 0,
    this.isLiked = false,
    this.isOwnedByMe = false,
  });

  bool get hasMoreReplies =>
      replyCount > replies.length || (replyCount > 0 && replies.isEmpty);

  Reflection copyWith({
    String? id,
    String? authorName,
    String? authorAvatarUrl,
    String? text,
    int? likeCount,
    DateTime? createdAt,
    List<Reflection>? replies,
    int? replyCount,
    bool? isLiked,
    bool? isOwnedByMe,
  }) {
    return Reflection(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      text: text ?? this.text,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      isLiked: isLiked ?? this.isLiked,
      isOwnedByMe: isOwnedByMe ?? this.isOwnedByMe,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorAvatarUrl,
        text,
        likeCount,
        createdAt,
        replies,
        replyCount,
        isLiked,
        isOwnedByMe,
      ];
}
