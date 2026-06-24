import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/scripture/domain/entities/scripture_post.dart';

abstract class ScriptureRepository {
  Future<Either<Failure, ScripturePost>> publishScripturePost({
    required String bibleReference,
    required String verseText,
    required bool allowComments,
    required bool notifyCommunity,
  });
}
