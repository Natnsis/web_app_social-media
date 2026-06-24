import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';

abstract final class CommentTreeUtils {
  CommentTreeUtils._();

  static Reflection? findReflection(
    List<Reflection> reflections,
    String commentId,
  ) {
    for (final item in reflections) {
      if (item.id == commentId) return item;
      final nested = findReflection(item.replies, commentId);
      if (nested != null) return nested;
    }
    return null;
  }

  static PostComment? findPostComment(
    List<PostComment> comments,
    String commentId,
  ) {
    for (final item in comments) {
      if (item.id == commentId) return item;
      final nested = findPostComment(item.replies, commentId);
      if (nested != null) return nested;
    }
    return null;
  }

  static List<Reflection> appendReflectionReply(
    List<Reflection> reflections,
    String parentId,
    Reflection reply,
  ) {
    return reflections
        .map((item) => _appendReflectionReply(item, parentId, reply))
        .toList();
  }

  static Reflection _appendReflectionReply(
    Reflection item,
    String parentId,
    Reflection reply,
  ) {
    if (item.id == parentId) {
      if (item.replies.any((existing) => existing.id == reply.id)) {
        return item;
      }
      return item.copyWith(
        replies: [...item.replies, reply],
        replyCount: item.replyCount + 1,
      );
    }
    if (item.replies.isEmpty) return item;

    final nested = item.replies
        .map((child) => _appendReflectionReply(child, parentId, reply))
        .toList();
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<Reflection> updateReflection(
    List<Reflection> reflections,
    String commentId,
    Reflection Function(Reflection current) update,
  ) {
    return reflections
        .map((item) => _updateReflection(item, commentId, update))
        .toList();
  }

  static Reflection _updateReflection(
    Reflection item,
    String commentId,
    Reflection Function(Reflection current) update,
  ) {
    if (item.id == commentId) return update(item);
    if (item.replies.isEmpty) return item;

    final nested = item.replies
        .map((child) => _updateReflection(child, commentId, update))
        .toList();
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<Reflection> removeReflection(
    List<Reflection> reflections,
    String commentId,
  ) {
    return reflections
        .where((item) => item.id != commentId)
        .map((item) => _removeReflection(item, commentId))
        .toList();
  }

  static Reflection _removeReflection(Reflection item, String commentId) {
    if (item.replies.isEmpty) return item;
    final nested = removeReflection(item.replies, commentId);
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<PostComment> appendPostCommentReply(
    List<PostComment> comments,
    String parentId,
    PostComment reply,
  ) {
    return comments
        .map((item) => _appendPostCommentReply(item, parentId, reply))
        .toList();
  }

  static PostComment _appendPostCommentReply(
    PostComment item,
    String parentId,
    PostComment reply,
  ) {
    if (item.id == parentId) {
      if (item.replies.any((existing) => existing.id == reply.id)) {
        return item;
      }
      return item.copyWith(
        replies: [...item.replies, reply],
        replyCount: item.replyCount + 1,
      );
    }
    if (item.replies.isEmpty) return item;

    final nested = item.replies
        .map((child) => _appendPostCommentReply(child, parentId, reply))
        .toList();
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<PostComment> updatePostComment(
    List<PostComment> comments,
    String commentId,
    PostComment Function(PostComment current) update,
  ) {
    return comments
        .map((item) => _updatePostComment(item, commentId, update))
        .toList();
  }

  static PostComment _updatePostComment(
    PostComment item,
    String commentId,
    PostComment Function(PostComment current) update,
  ) {
    if (item.id == commentId) return update(item);
    if (item.replies.isEmpty) return item;

    final nested = item.replies
        .map((child) => _updatePostComment(child, commentId, update))
        .toList();
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<PostComment> removePostComment(
    List<PostComment> comments,
    String commentId,
  ) {
    return comments
        .where((item) => item.id != commentId)
        .map((item) => _removePostComment(item, commentId))
        .toList();
  }

  static PostComment _removePostComment(PostComment item, String commentId) {
    if (item.replies.isEmpty) return item;
    final nested = removePostComment(item.replies, commentId);
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<PostComment> attachPostCommentReplies(
    List<PostComment> comments,
    String parentId,
    List<PostComment> replies,
  ) {
    return comments
        .map((item) => _attachPostCommentReplies(item, parentId, replies))
        .toList();
  }

  static PostComment _attachPostCommentReplies(
    PostComment item,
    String parentId,
    List<PostComment> replies,
  ) {
    if (item.id == parentId) {
      final merged = _mergePostCommentsById(item.replies, replies);
      final count = merged.length > item.replyCount
          ? merged.length
          : item.replyCount;
      return item.copyWith(
        replies: merged,
        replyCount: count > 0 ? count : item.replyCount,
      );
    }
    if (item.replies.isEmpty) return item;

    final nested = item.replies
        .map((child) => _attachPostCommentReplies(child, parentId, replies))
        .toList();
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<Reflection> attachReflectionReplies(
    List<Reflection> reflections,
    String parentId,
    List<Reflection> replies,
  ) {
    return reflections
        .map((item) => _attachReflectionReplies(item, parentId, replies))
        .toList();
  }

  static Reflection _attachReflectionReplies(
    Reflection item,
    String parentId,
    List<Reflection> replies,
  ) {
    if (item.id == parentId) {
      final merged = _mergeReflectionsById(item.replies, replies);
      final count = merged.length > item.replyCount
          ? merged.length
          : item.replyCount;
      return item.copyWith(
        replies: merged,
        replyCount: count > 0 ? count : item.replyCount,
      );
    }
    if (item.replies.isEmpty) return item;

    final nested = item.replies
        .map((child) => _attachReflectionReplies(child, parentId, replies))
        .toList();
    if (nested == item.replies) return item;
    return item.copyWith(replies: nested);
  }

  static List<PostComment> _mergePostCommentsById(
    List<PostComment> existing,
    List<PostComment> incoming,
  ) {
    final byId = {for (final item in existing) item.id: item};
    for (final item in incoming) {
      byId[item.id] = item;
    }
    return byId.values.toList();
  }

  static List<Reflection> _mergeReflectionsById(
    List<Reflection> existing,
    List<Reflection> incoming,
  ) {
    final byId = {for (final item in existing) item.id: item};
    for (final item in incoming) {
      byId[item.id] = item;
    }
    return byId.values.toList();
  }
}
