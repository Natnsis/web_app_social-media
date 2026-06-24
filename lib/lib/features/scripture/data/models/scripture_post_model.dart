import 'package:faithconnect/features/scripture/domain/entities/scripture_post.dart';

class ScripturePostModel extends ScripturePost {
  const ScripturePostModel({
    required super.id,
    required super.bibleReference,
    required super.verseText,
    required super.allowComments,
    required super.notifyCommunity,
  });

  factory ScripturePostModel.fromJson(Map<String, dynamic> json) {
    return ScripturePostModel(
      id: json['id']?.toString() ?? '',
      bibleReference: json['reference'] as String? ??
          json['bibleReference'] as String? ??
          '',
      verseText: json['verse'] as String? ??
          json['verseText'] as String? ??
          '',
      allowComments: json['allowComments'] as bool? ?? true,
      notifyCommunity: json['notifyCommunity'] as bool? ?? false,
    );
  }

  ScripturePost toEntity() => ScripturePost(
        id: id,
        bibleReference: bibleReference,
        verseText: verseText,
        allowComments: allowComments,
        notifyCommunity: notifyCommunity,
      );
}
