import 'package:dartz/dartz.dart';

import 'package:faithconnect/core/error/failures.dart';

import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';

import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';

import 'package:faithconnect/features/event/application/event_service.dart';
import 'package:faithconnect/features/post/domain/repositories/post_repository.dart';
import 'package:faithconnect/features/scripture/application/scripture_service.dart';

import 'package:faithconnect/features/scripture/domain/entities/scripture_post.dart';



class PostComposeService {

  final PostRepository _postRepository;
  final ScriptureService _scriptureService;
  final EventService _eventService;

  PostComposeService(
    this._postRepository,
    this._scriptureService,
    this._eventService,
  );



  Future<Either<Failure, String>> publish(PostComposeDraft draft) {

    return switch (draft.selectedType) {

      PostComposeType.post => _postRepository.createTextPost(draft),

      PostComposeType.short => _postRepository.createShort(draft),

      PostComposeType.scripture => _publishScripture(draft),

      PostComposeType.event => _eventService.createEvent(draft),

      PostComposeType.image ||

      PostComposeType.video ||

      PostComposeType.attachment =>

        _postRepository.publishComposeStub(draft),

    };

  }



  Future<Either<Failure, String>> _publishScripture(

    PostComposeDraft draft,

  ) async {

    final result = await _scriptureService.publishScripturePost(

      bibleReference: draft.bibleReference.trim(),

      verseText: draft.verseText.trim(),

      allowComments: draft.allowComments,

      notifyCommunity: draft.notifyCommunity,

    );

    return result.map((ScripturePost post) => post.id);

  }

}

