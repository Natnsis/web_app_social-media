import 'package:faithconnect/features/campaign/data/dto/create_campaign_dto.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';

abstract final class CreateCampaignMapper {
  CreateCampaignMapper._();

  static CreateCampaignDto fromDraft(NewCampaignDraft draft) {
    final goal = draft.parsedGoal ?? 0;
    final startAt = _toIso8601Utc(DateTime.now());
    final endAt = _parseEndDateToIso(draft.endDate);

    return CreateCampaignDto(
      title: draft.title.trim(),
      description: draft.description.trim(),
      goalAmount: goal,
      startAt: startAt,
      endAt: endAt,
      isActive: true,
      imagePath: draft.coverImagePath,
    );
  }

  static String _toIso8601Utc(DateTime value) {
    return value.toUtc().toIso8601String();
  }

  static String? _parseEndDateToIso(String endDate) {
    final trimmed = endDate.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split('/');
    if (parts.length != 3) return null;

    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) return null;

    return _toIso8601Utc(DateTime(year, month, day, 23, 59, 59));
  }
}
