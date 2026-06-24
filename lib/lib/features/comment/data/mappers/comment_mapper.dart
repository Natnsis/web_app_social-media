import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/comment/data/dto/comment_api_dto.dart';
import 'package:faithconnect/features/post/domain/entities/post_comment.dart';
import 'package:faithconnect/features/shortvideo/domain/entities/reflection.dart';

abstract final class CommentMapper {
  CommentMapper._();

  /// Loads the signed-in actor ids used to infer comment ownership.
  static Future<({String? userId, String? churchId})> currentActorIds() async {
    final user = await SharedPrefsService.getUser();
    final userId = user?.id ?? await SharedPrefsService.getUserId();
    return (userId: userId, churchId: user?.churchId);
  }

  static Reflection toReflection(
    CommentApiDto dto, {
    String? currentUserId,
    String? currentChurchId,
  }) {
    return Reflection(
      id: dto.id,
      authorName: _authorName(dto.authorName),
      authorAvatarUrl: MediaUrlResolver.normalize(
        dto.authorAvatarUrl,
        imageOnly: true,
      ),
      text: dto.body.trim(),
      likeCount: dto.likeCount,
      createdAt: dto.createdAt ?? DateTime.now(),
      replyCount: dto.replyCount,
      isLiked: dto.isLikedByMe,
      isOwnedByMe: dto.ownedBy(
        userId: currentUserId,
        churchId: currentChurchId,
      ),
    );
  }

  /// Builds an ordered tree of [Reflection]s from a flat list of DTOs.
  /// DTOs that have a `parentId` found in the same list are nested as children;
  /// DTOs without a parent (or whose parent is not in the list) become roots.
  static List<Reflection> buildReflectionTree(
    List<CommentApiDto> dtos, {
    String? currentUserId,
    String? currentChurchId,
  }) {
    if (dtos.isEmpty) return const [];

    final Map<String, List<CommentApiDto>> childrenMap = {};
    final Map<String, CommentApiDto> dtoMap = {for (final d in dtos) d.id: d};

    for (final dto in dtos) {
      final pid = dto.parentId;
      if (pid != null && pid.isNotEmpty && dtoMap.containsKey(pid)) {
        childrenMap.putIfAbsent(pid, () => []).add(dto);
      }
    }

    Reflection buildNode(CommentApiDto dto) {
      final children = (childrenMap[dto.id] ?? []).map(buildNode).toList();
      final base = toReflection(
        dto,
        currentUserId: currentUserId,
        currentChurchId: currentChurchId,
      );
      return children.isEmpty ? base : base.copyWith(replies: children);
    }

    // Roots = DTOs whose parentId is absent OR not in the fetched list
    final roots = dtos.where((d) {
      final pid = d.parentId;
      return pid == null || pid.isEmpty || !dtoMap.containsKey(pid);
    }).map(buildNode).toList();

    // Fallback: if we can't distinguish roots, return flat list
    return roots.isEmpty ? dtos.map((d) => toReflection(d, currentUserId: currentUserId, currentChurchId: currentChurchId)).toList() : roots;
  }

  static PostComment toPostComment(
    CommentApiDto dto, {
    String? currentUserId,
    String? currentChurchId,
  }) {
    return PostComment(
      id: dto.id,
      authorName: _authorName(dto.authorName),
      authorAvatarUrl: MediaUrlResolver.normalize(
        dto.authorAvatarUrl,
        imageOnly: true,
      ),
      text: dto.body.trim(),
      likeCount: dto.likeCount,
      createdAt: dto.createdAt ?? DateTime.now(),
      replyCount: dto.replyCount,
      isLiked: dto.isLikedByMe,
      isOwnedByMe: dto.ownedBy(
        userId: currentUserId,
        churchId: currentChurchId,
      ),
    );
  }

  static String _authorName(String? name) {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return 'You';
  }
}
