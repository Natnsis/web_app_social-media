import 'package:equatable/equatable.dart';

class ScripturePost extends Equatable {
  final String id;
  final String bibleReference;
  final String verseText;
  final bool allowComments;
  final bool notifyCommunity;

  const ScripturePost({
    required this.id,
    required this.bibleReference,
    required this.verseText,
    required this.allowComments,
    required this.notifyCommunity,
  });

  @override
  List<Object?> get props => [
        id,
        bibleReference,
        verseText,
        allowComments,
        notifyCommunity,
      ];
}
