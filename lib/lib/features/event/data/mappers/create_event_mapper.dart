import 'package:faithconnect/features/event/data/dto/create_event_dto.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:intl/intl.dart';

abstract final class CreateEventMapper {
  CreateEventMapper._();

  static CreateEventDto fromComposeDraft(PostComposeDraft draft) {
    final date = parseDateLabel(draft.eventDateLabel);
    final time = parseTimeLabel(draft.eventTimeLabel);

    return CreateEventDto(
      title: draft.eventTitle.trim(),
      description: draft.eventDetails.trim(),
      date: date ?? '',
      time: time ?? '',
      isActive: true,
      imagePath: draft.uploadedMedia?.filePath,
    );
  }

  /// Parses UI label like `October 24, 2024` to `YYYY-MM-DD`.
  static String? parseDateLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return null;

    try {
      final parsed = DateFormat('MMMM d, y').parse(trimmed);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return null;
    }
  }

  /// Parses UI label like `7:00 PM` to 24-hour `HH:mm`.
  static String? parseTimeLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return null;

    for (final pattern in ['jm', 'HH:mm', 'H:mm']) {
      try {
        final parsed = DateFormat(pattern).parse(trimmed);
        return DateFormat('HH:mm').format(parsed);
      } catch (_) {
        continue;
      }
    }

    return null;
  }
}
