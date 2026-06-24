import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/scripture/data/datasources/scripture_remote_datasource.dart';
import 'package:faithconnect/features/scripture/domain/entities/scripture_post.dart';
import 'package:faithconnect/features/scripture/domain/repositories/scripture_repository.dart';

class ScriptureRepositoryImpl implements ScriptureRepository {
  final ScriptureRemoteDataSource remoteDataSource;

  ScriptureRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ScripturePost>> publishScripturePost({
    required String bibleReference,
    required String verseText,
    required bool allowComments,
    required bool notifyCommunity,
  }) async {
    try {
      final post = await remoteDataSource.publishScripturePost(
        bibleReference: bibleReference,
        verseText: verseText,
        allowComments: allowComments,
        notifyCommunity: notifyCommunity,
      );
      return Right(post.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}