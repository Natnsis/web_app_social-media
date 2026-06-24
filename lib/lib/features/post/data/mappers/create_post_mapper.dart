import 'package:faithconnect/features/post/data/dto/create_post_dto.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';

/// Maps a **text** compose draft to [CreatePostDto] for `POST /v1/posts`.
abstract final class CreatePostMapper {
  CreatePostMapper._();

  static CreatePostDto fromTextDraft(PostComposeDraft draft) {
    if (draft.selectedType != PostComposeType.post) {
      throw ArgumentError(
        'CreatePostMapper only supports PostComposeType.text',
      );
    }

    return CreatePostDto(
      content: _textContent(draft),
      filePaths: _localFilePaths(draft),
    );
  }

  static String _textContent(PostComposeDraft draft) {
    final text = draft.textBody.trim();
    if (text.isNotEmpty) return text;
    if (draft.uploadedMedia != null) return 'Shared a post';
    return '';
  }

  static List<String> _localFilePaths(PostComposeDraft draft) {
    final path = draft.uploadedMedia?.filePath.trim();
    if (path == null || path.isEmpty) return const [];
    return [path];
  }
}
