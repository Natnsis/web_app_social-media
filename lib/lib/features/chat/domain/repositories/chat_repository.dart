import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatRoom>>> getRooms();

  Future<Either<Failure, ChatRoom>> getRoom(String roomId);

  Future<Either<Failure, String>> uploadAttachment(String filePath, {bool isGroup = false});

  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId);

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String roomId,
    required String content,
    String? attachmentPath,
    String? attachmentName,
    MediaUploadKind? attachmentKind,
  });

  Future<Either<Failure, void>> deleteMessage({
    required String roomId,
    required String messageId,
  });

  Future<Either<Failure, List<GroupModeratorCandidate>>>
      getModeratorCandidates();

  Future<Either<Failure, String>> createGroup(NewGroupDraft draft);

  void prepareDirectConversation({
    required String userId,
    required String displayName,
    String? avatarUrl,
  });

  Future<Either<Failure, void>> requestGroupJoin(String groupId);

  Future<Either<Failure, List<GroupJoinRequest>>> fetchGroupJoinRequests(
    String groupId,
  );

  Future<Either<Failure, List<GroupMember>>> fetchGroupMembers(String groupId);

  Future<Either<Failure, void>> approveGroupJoinRequest({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, void>> rejectGroupJoinRequest({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, void>> inviteGroupMember({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, void>> banGroupMember({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, void>> leaveGroup(String groupId);

  Future<Either<Failure, void>> removeGroupMember({
    required String groupId,
    required String userId,
  });

  Future<Either<Failure, void>> blockUser(String userId);

  Future<Either<Failure, void>> unblockUser(String userId);

  Future<Either<Failure, List<String>>> getBlockedUserIds();
}
