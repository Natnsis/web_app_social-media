import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';
import 'package:faithconnect/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChatRoom>>> getRooms() async {
    try {
      final rooms = await remoteDataSource.getRooms();
      return Right(rooms.map((room) => room.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatRoom>> getRoom(String roomId) async {
    try {
      final room = await remoteDataSource.getRoom(roomId);
      if (room == null) {
        return const Left(ServerFailure(message: 'Chat not found'));
      }
      return Right(room.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId) async {
    try {
      final messages = await remoteDataSource.getMessages(roomId);
      return Right(messages.map((message) => message.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String roomId,
    required String content,
    String? attachmentPath,
    String? attachmentName,
    MediaUploadKind? attachmentKind,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        roomId: roomId,
        content: content,
        attachmentPath: attachmentPath,
        attachmentName: attachmentName,
        attachmentKind: attachmentKind,
      );
      return Right(message.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAttachment(String filePath, {bool isGroup = false}) async {
    try {
      final url = await remoteDataSource.uploadAttachment(filePath, isGroup: isGroup);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    try {
      await remoteDataSource.deleteMessage(roomId: roomId, messageId: messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupModeratorCandidate>>>
      getModeratorCandidates() async {
    try {
      final candidates = await remoteDataSource.getModeratorCandidates();
      return Right(candidates);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  void prepareDirectConversation({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) {
    remoteDataSource.cacheDirectRoom(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<Either<Failure, void>> requestGroupJoin(String groupId) async {
    try {
      await remoteDataSource.requestGroupJoin(groupId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupJoinRequest>>> fetchGroupJoinRequests(
    String groupId,
  ) async {
    try {
      final requests = await remoteDataSource.fetchGroupJoinRequests(groupId);
      return Right(requests);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GroupMember>>> fetchGroupMembers(
    String groupId,
  ) async {
    try {
      final members = await remoteDataSource.fetchGroupMembers(groupId);
      return Right(members);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveGroupJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.approveGroupJoinRequest(
        groupId: groupId,
        userId: userId,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectGroupJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.rejectGroupJoinRequest(
        groupId: groupId,
        userId: userId,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> inviteGroupMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.inviteGroupMember(
        groupId: groupId,
        userId: userId,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createGroup(NewGroupDraft draft) async {
    try {
      final roomId = await remoteDataSource.createGroup(draft);
      return Right(roomId);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> banGroupMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.banGroupMember(
        groupId: groupId,
        userId: userId,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId) async {
    try {
      await remoteDataSource.leaveGroup(groupId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeGroupMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.removeGroupMember(
        groupId: groupId,
        userId: userId,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(String userId) async {
    try {
      await remoteDataSource.blockUser(userId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(String userId) async {
    try {
      await remoteDataSource.unblockUser(userId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBlockedUserIds() async {
    try {
      final ids = await remoteDataSource.getBlockedUserIds();
      return Right(ids);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
