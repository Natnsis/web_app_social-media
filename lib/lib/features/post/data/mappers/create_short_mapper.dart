import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/post/data/dto/create_short_dto.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';

/// Maps a **short** compose draft to [CreateShortDto] for `POST /v1/shorts`.
abstract final class CreateShortMapper {
  CreateShortMapper._();

  static CreateShortDto fromDraft(PostComposeDraft draft) {
    if (draft.selectedType != PostComposeType.short) {
      throw ArgumentError(
        'CreateShortMapper only supports PostComposeType.short',
      );
    }

    final media = draft.uploadedMedia;
    if (media == null || media.kind != MediaUploadKind.video) {
      throw ArgumentError('Short compose requires a video file.');
    }

    final caption = draft.caption.trim();

    return CreateShortDto(
      title: caption.isNotEmpty ? caption : null,
      description: caption.isNotEmpty ? caption : null,
      videoPath: media.filePath,
    );
  }
}
