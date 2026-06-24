import 'package:dartz/dartz.dart';
import 'package:faithconnect/core/error/failures.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';
import 'package:faithconnect/features/chat/domain/repositories/chat_repository.dart';

class ChatService {
  final ChatRepository _repository;

  ChatService(this._repository);

  Future<Either<Failure, List<ChatRoom>>> getRooms() => _repository.getRooms();

  Future<Either<Failure, ChatRoom>> getRoom(String roomId) =>
      _repository.getRoom(roomId);

  Future<Either<Failure, String>> uploadAttachment(String filePath, {bool isGroup = false}) =>
      _repository.uploadAttachment(filePath, isGroup: isGroup);

  Future<Either<Failure, List<ChatMessage>>> getMessages(String roomId) =>
      _repository.getMessages(roomId);

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String roomId,
    required String content,
    String? attachmentPath,
    String? attachmentName,
    MediaUploadKind? attachmentKind,
  }) {
    return _repository.sendMessage(
      roomId: roomId,
      content: content,
      attachmentPath: attachmentPath,
      attachmentName: attachmentName,
      attachmentKind: attachmentKind,
    );
  }

  Future<Either<Failure, void>> deleteMessage({
    required String roomId,
    required String messageId,
  }) =>
      _repository.deleteMessage(roomId: roomId, messageId: messageId);

  Future<Either<Failure, List<GroupModeratorCandidate>>>
      getModeratorCandidates() => _repository.getModeratorCandidates();

  Future<Either<Failure, String>> createGroup(NewGroupDraft draft) =>
      _repository.createGroup(draft);

  void prepareDirectConversation({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) {
    _repository.prepareDirectConversation(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  Future<Either<Failure, void>> requestGroupJoin(String groupId) =>
      _repository.requestGroupJoin(groupId);

  Future<Either<Failure, List<GroupJoinRequest>>> fetchGroupJoinRequests(
    String groupId,
  ) =>
      _repository.fetchGroupJoinRequests(groupId);

  Future<Either<Failure, List<GroupMember>>> fetchGroupMembers(
    String groupId,
  ) =>
      _repository.fetchGroupMembers(groupId);

  Future<Either<Failure, void>> approveGroupJoinRequest({
    required String groupId,
    required String userId,
  }) =>
      _repository.approveGroupJoinRequest(groupId: groupId, userId: userId);

  Future<Either<Failure, void>> rejectGroupJoinRequest({
    required String groupId,
    required String userId,
  }) =>
      _repository.rejectGroupJoinRequest(groupId: groupId, userId: userId);

  Future<Either<Failure, void>> inviteGroupMember({
    required String groupId,
    required String userId,
  }) =>
      _repository.inviteGroupMember(groupId: groupId, userId: userId);

  Future<Either<Failure, void>> banGroupMember({
    required String groupId,
    required String userId,
  }) =>
      _repository.banGroupMember(groupId: groupId, userId: userId);

  Future<Either<Failure, void>> leaveGroup(String groupId) =>
      _repository.leaveGroup(groupId);

  Future<Either<Failure, void>> removeGroupMember({
    required String groupId,
    required String userId,
  }) =>
      _repository.removeGroupMember(groupId: groupId, userId: userId);

  Future<Either<Failure, void>> blockUser(String userId) =>
      _repository.blockUser(userId);

  Future<Either<Failure, void>> unblockUser(String userId) =>
      _repository.unblockUser(userId);

  Future<Either<Failure, List<String>>> getBlockedUserIds() =>
      _repository.getBlockedUserIds();
}
