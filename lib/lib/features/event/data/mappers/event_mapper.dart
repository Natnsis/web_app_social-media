import 'package:faithconnect/features/event/data/dto/event_api_dto.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:intl/intl.dart';

abstract final class EventMapper {
  EventMapper._();

  static ChurchEvent fromDto(EventApiDto dto) {
    return ChurchEvent(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      date: dto.date,
      time: dto.time,
      dateTimeLabel: formatDateTimeLabel(dto.date, dto.time),
      churchId: dto.churchId,
      churchName: dto.churchName,
      location: dto.location ?? '',
      imageUrl: dto.imageUrl,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
    );
  }

  static String formatDateTimeLabel(String date, String time) {
    final dateLabel = _formatDate(date);
    final timeLabel = _formatTime(time);

    if (dateLabel != null && timeLabel != null) {
      return '$dateLabel · $timeLabel';
    }
    if (dateLabel != null) return dateLabel;
    if (timeLabel != null) return timeLabel;
    return 'Date TBA';
  }

  static String? _formatDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return DateFormat('MMMM d, y').format(parsed);
    }

    final parts = trimmed.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateFormat('MMMM d, y').format(DateTime(year, month, day));
      }
    }

    return trimmed;
  }

  static String? _formatTime(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    for (final pattern in ['HH:mm', 'H:mm']) {
      try {
        final parsed = DateFormat(pattern).parse(trimmed);
        return DateFormat.jm().format(parsed);
      } catch (_) {
        continue;
      }
    }

    return trimmed;
  }
}
