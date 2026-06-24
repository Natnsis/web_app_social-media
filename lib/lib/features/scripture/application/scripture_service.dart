import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/scripture/domain/entities/scripture_post.dart';
import 'package:faithconnect/features/scripture/domain/repositories/scripture_repository.dart';

class ScriptureService {
  final ScriptureRepository _repository;

  ScriptureService(this._repository);

  Future<Either<Failure, ScripturePost>> publishScripturePost({
    required String bibleReference,
    required String verseText,
    required bool allowComments,
    required bool notifyCommunity,
  }) =>
      _repository.publishScripturePost(
        bibleReference: bibleReference,
        verseText: verseText,
        allowComments: allowComments,
        notifyCommunity: notifyCommunity,
      );
}
