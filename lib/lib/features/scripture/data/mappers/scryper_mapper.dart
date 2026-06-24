import 'package:faithconnect/core/utils/formatters.dart';
import 'package:faithconnect/features/home/data/models/home_feed_model.dart';
import 'package:faithconnect/features/scripture/data/dto/scryper_api_dto.dart';
import 'package:faithconnect/features/scripture/data/models/scripture_post_model.dart';

abstract final class ScryperMapper {
  ScryperMapper._();

  static DailyVerseModel toDailyVerseModel(ScryperApiDto dto) {
    final quote = dto.verse.trim();
    final reference = dto.reference.trim();
    final churchName = dto.churchName?.trim();
    final subtitle = churchName != null && churchName.isNotEmpty
        ? churchName
        : dto.createdAt != null
            ? formatShortTimeAgo(dto.createdAt!)
            : "Today's scripture";

    return DailyVerseModel(
      quote: quote,
      reference: reference,
      subtitle: subtitle,
    );
  }

  static List<DailyVerseModel> toDailyVerseModels(List<ScryperApiDto> scrypers) {
    final valid = scrypers
        .where(
          (s) =>
              s.verse.trim().isNotEmpty && s.reference.trim().isNotEmpty,
        )
        .toList();

    if (valid.isEmpty) return const [];

    valid.sort((a, b) {
      if (a.isActive != b.isActive) {
        return a.isActive ? -1 : 1;
      }
      final aTime = a.updatedAt ??
          a.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ??
          b.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return valid.map(toDailyVerseModel).toList();
  }

  /// Picks the best active scryper for the home daily verse card.
  static ScryperApiDto? pickForDailyVerse(
    List<ScryperApiDto> scrypers, {
    String? preferredChurchId,
  }) {
    final active = scrypers
        .where(
          (s) =>
              s.isActive &&
              s.verse.trim().isNotEmpty &&
              s.reference.trim().isNotEmpty,
        )
        .toList();

    if (active.isEmpty) return null;

    active.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    final churchId = preferredChurchId?.trim();
    if (churchId != null && churchId.isNotEmpty) {
      for (final scryper in active) {
        if (scryper.churchId == churchId) return scryper;
      }
    }

    return active.first;
  }

  static ScripturePostModel toScripturePost(
    ScryperApiDto dto, {
    required bool allowComments,
    required bool notifyCommunity,
  }) {
    return ScripturePostModel(
      id: dto.id,
      bibleReference: dto.reference.trim(),
      verseText: dto.verse.trim(),
      allowComments: allowComments,
      notifyCommunity: notifyCommunity,
    );
  }
}
