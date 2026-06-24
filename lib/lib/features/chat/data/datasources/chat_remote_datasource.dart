import 'package:dio/dio.dart';
import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/core/network/api_create_response.dart';
import 'package:faithconnect/core/network/api_error_mapper.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/chat/data/dto/group_api_dto.dart';
import 'package:faithconnect/features/chat/data/dto/group_join_request_api_dto.dart';
import 'package:faithconnect/features/chat/data/dto/group_member_api_dto.dart';
import 'package:faithconnect/features/chat/data/mappers/group_join_request_mapper.dart';
import 'package:faithconnect/features/chat/data/mappers/group_member_mapper.dart';
import 'package:faithconnect/features/chat/data/dto/messaging_message_api_dto.dart';
import 'package:faithconnect/features/chat/data/mappers/chat_room_mapper.dart';
import 'package:faithconnect/features/chat/data/mappers/create_group_mapper.dart';
import 'package:faithconnect/features/chat/data/mappers/messaging_inbox_mapper.dart';
import 'package:faithconnect/features/chat/data/mappers/group_message_mapper.dart';
import 'package:faithconnect/features/comment/data/dto/comment_api_dto.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/core/network/api_list_response.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/features/chat/data/models/chat_message_model.dart';
import 'package:faithconnect/features/user/data/dto/user_search_api_dto.dart';
import 'package:faithconnect/features/chat/data/models/chat_room_model.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:faithconnect/features/chat/domain/entities/new_group_draft.dart';
import 'package:faithconnect/core/utils/group_access_errors.dart';
import 'package:intl/intl.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoomModel>> getRooms();

  Future<ChatRoomModel?> getRoom(String roomId);

  Future<List<ChatMessageModel>> getMessages(String roomId);

  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String content,
    String? attachmentPath,
    String? attachmentName,
    MediaUploadKind? attachmentKind,
  });

  Future<String> uploadAttachment(String filePath, {bool isGroup = false});

  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  });

  Future<List<GroupModeratorCandidate>> getModeratorCandidates();

  Future<String> createGroup(NewGroupDraft draft);

  void cacheDirectRoom({
    required String userId,
    required String displayName,
    String? avatarUrl,
  });

  Future<void> requestGroupJoin(String groupId);

  Future<List<GroupJoinRequest>> fetchGroupJoinRequests(String groupId);

  Future<List<GroupMember>> fetchGroupMembers(String groupId);

  Future<void> approveGroupJoinRequest({
    required String groupId,
    required String userId,
  });

  Future<void> rejectGroupJoinRequest({
    required String groupId,
    required String userId,
  });

  Future<void> inviteGroupMember({
    required String groupId,
    required String userId,
  });

  Future<void> banGroupMember({
    required String groupId,
    required String userId,
  });

  Future<void> leaveGroup(String groupId);

  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
  });

  Future<void> blockUser(String userId);

  Future<void> unblockUser(String userId);

  Future<List<String>> getBlockedUserIds();
}

class _RoomPreview {
  final String lastMessage;
  final String? lastSenderName;
  final DateTime updatedAt;

  const _RoomPreview({
    required this.lastMessage,
    this.lastSenderName,
    required this.updatedAt,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;
  final List<ChatMessageModel> _sentMessages = [];
  final Map<String, _RoomPreview> _roomPreviews = {};
  final Map<String, ChatRoomModel> _groupRoomCache = {};
  final Map<String, ChatRoomModel> _directRoomCache = {};
  final Map<String, List<ChatMessageModel>> _directMessagesCache = {};
  final Map<String, MessagingConversationApiDto> _directConversationCache = {};

  @override
  Future<List<ChatRoomModel>> getRooms() async {
    final directRooms = await _fetchDirectRooms();
    final peerKeyedRooms = _directRoomCache.values
        .where(
          (room) => !directRooms.any(
            (apiRoom) =>
                apiRoom.peerUserId != null &&
                apiRoom.peerUserId == room.peerUserId,
          ),
        )
        .map(_applyPreview)
        .toList(growable: false);
    final groupRooms = await _fetchGroupRooms();
    final merged = [...directRooms, ...peerKeyedRooms, ...groupRooms];
    merged.sort(
      (a, b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
    return merged;
  }

  Future<String?> _resolveCurrentUserId() async {
    final storedId = await SharedPrefsService.getUserId();
    if (storedId != null && storedId.trim().isNotEmpty) return storedId.trim();
    final user = await SharedPrefsService.getUser();
    final userId = user?.id?.trim();
    if (userId != null && userId.isNotEmpty) return userId;
    return null;
  }

  Future<List<MessagingMessageApiDto>> _fetchMessagingMessages({
    String? conversationId,
  }) async {
    final response = await _dio.get<dynamic>(
      MessagingApiEndpoint.messages,
      queryParameters: conversationId == null
          ? null
          : MessagingApiEndpoint.messagesQuery(conversationId: conversationId),
    );
    final parsed = ApiListResponse.parse(
      response.data,
      MessagingMessageApiDto.fromJson,
    );
    return parsed.data;
  }

  void _cacheMessagingPayload(
    List<MessagingMessageApiDto> messages, {
    required String? currentUserId,
    bool replaceAll = false,
  }) {
    for (final message in messages) {
      final conversation = message.conversation;
      if (conversation != null && conversation.id.isNotEmpty) {
        _directConversationCache[conversation.id] = conversation;
      }
    }

    final messagesByConversation = MessagingInboxMapper.messagesByConversation(
      messages,
      currentUserId: currentUserId,
    );

    if (replaceAll) {
      _directMessagesCache
        ..clear()
        ..addAll(messagesByConversation);
    } else {
      _directMessagesCache.addAll(messagesByConversation);
    }

    final rooms = MessagingInboxMapper.roomsFromMessages(
      messages,
      currentUserId: currentUserId,
    );
    for (final room in rooms) {
      _directRoomCache[room.id] = room;
    }
  }

  Future<List<ChatRoomModel>> _fetchDirectRooms() async {
    try {
      final currentUserId = await _resolveCurrentUserId();
      final messages = await _fetchMessagingMessages();
      _cacheMessagingPayload(
        messages,
        currentUserId: currentUserId,
        replaceAll: true,
      );

      final applied = _directRoomCache.values.map(_applyPreview).toList()
        ..sort(
          (a, b) => (b.updatedAt ?? DateTime(0)).compareTo(
            a.updatedAt ?? DateTime(0),
          ),
        );
      return applied;
    } on DioException catch (e) {
      FaithLogger.w('ChatRemote', 'direct messages list failed: ${e.message}');
      return _directRoomCache.values.map(_applyPreview).toList(growable: false);
    }
  }

  Future<List<ChatMessageModel>> _fetchDirectThreadMessages(
    String conversationId,
  ) async {
    try {
      final currentUserId = await _resolveCurrentUserId();
      final messages = await _fetchMessagingMessages(
        conversationId: conversationId,
      );
      if (messages.isEmpty) {
        return _directMessagesCache[conversationId] ?? const [];
      }

      _cacheMessagingPayload(
        messages,
        currentUserId: currentUserId,
        replaceAll: false,
      );
      return _directMessagesCache[conversationId] ?? const [];
    } on DioException catch (e) {
      FaithLogger.w(
        'ChatRemote',
        'direct thread messages failed: ${e.message}',
      );
      return _directMessagesCache[conversationId] ?? const [];
    }
  }

  Future<List<ChatRoomModel>> _fetchGroupRooms() async {
    try {
      final response = await _dio.get<dynamic>(GroupsApiEndpoint.list);
      final parsed = ApiListResponse.parse(response.data, GroupApiDto.fromJson);

      final rooms = parsed.data
          .where((dto) => dto.id.isNotEmpty)
          .map(ChatRoomMapper.fromGroupDto)
          .map(_applyPreview)
          .toList();

      for (final room in rooms) {
        _groupRoomCache[room.id] = room;
      }
      return rooms;
    } on DioException catch (e) {
      FaithLogger.w('ChatRemote', 'groups list failed: ${e.message}');
      return const [];
    }
  }

  @override
  Future<ChatRoomModel?> getRoom(String roomId) async {
    final trimmedId = roomId.trim();
    if (trimmedId.isEmpty) return null;

    var cachedDirect = _directRoomCache[trimmedId];
    if (cachedDirect == null) {
      for (final room in _directRoomCache.values) {
        if (room.peerUserId == trimmedId) {
          cachedDirect = room;
          break;
        }
      }
    }
    if (cachedDirect != null) {
      return _applyPreview(cachedDirect);
    }

    await _fetchDirectRooms();
    cachedDirect = _directRoomCache[trimmedId];
    if (cachedDirect == null) {
      for (final room in _directRoomCache.values) {
        if (room.peerUserId == trimmedId) {
          cachedDirect = room;
          break;
        }
      }
    }
    if (cachedDirect != null) {
      return _applyPreview(cachedDirect);
    }

    final cachedGroup = _groupRoomCache[trimmedId];
    if (cachedGroup != null) {
      return _applyPreview(cachedGroup);
    }

    final apiGroup = await _fetchGroupRoom(trimmedId);
    if (apiGroup != null) {
      return _applyPreview(apiGroup);
    }

    // Newly created API groups may not be indexed yet — still open the thread.
    return _applyPreview(_fallbackGroupRoom(trimmedId));
  }

  Future<ChatRoomModel?> _fetchGroupRoom(String roomId) async {
    try {
      final response = await _dio.get<dynamic>(
        GroupsApiEndpoint.detail(roomId),
      );
      final dto = GroupApiDto.parseSingle(response.data);
      if (dto == null || dto.id.isEmpty) return null;

      final room = ChatRoomMapper.fromGroupDto(dto);
      _groupRoomCache[room.id] = room;
      return room;
    } on DioException catch (e) {
      FaithLogger.w('ChatRemote', 'group detail failed: ${e.message}');
      return null;
    }
  }

  ChatRoomModel _fallbackGroupRoom(String roomId) {
    return ChatRoomModel(
      id: roomId,
      title: 'Group',
      type: ChatRoomType.group,
      initials: 'G',
    );
  }

  void _rememberGroupRoom(ChatRoomModel room) {
    _groupRoomCache[room.id] = room;
  }

  @override
  void cacheDirectRoom({
    required String userId,
    required String displayName,
    String? avatarUrl,
  }) {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) return;

    final title = displayName.trim();
    _directRoomCache[trimmedId] = ChatRoomModel(
      id: trimmedId,
      title: title.isNotEmpty ? title : 'Member',
      type: ChatRoomType.direct,
      peerUserId: trimmedId,
      avatarUrl: avatarUrl,
      initials: title.isNotEmpty ? title[0].toUpperCase() : 'M',
    );
  }

  Future<List<ChatMessageModel>> _fetchGroupMessages(String groupId) async {
    try {
      final currentUserId = await _resolveCurrentUserId();
      final response = await _dio.get<dynamic>(
        GroupsApiEndpoint.groupMessages(groupId),
      );

      final dtos = CommentApiDto.flattenList(response.data);
      final messages = dtos
          .map(
            (dto) => GroupMessageMapper.fromCommentDto(
              dto,
              roomId: groupId,
              currentUserId: currentUserId,
            ),
          )
          .toList();

      return messages;
    } on DioException catch (e) {
      if (_isExpectedNonMemberGroupAccess(e)) return const [];
      FaithLogger.w('ChatRemote', 'group messages failed: ${e.message}');
      return const [];
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String roomId) async {
    final trimmedId = roomId.trim();
    if (trimmedId.isEmpty) return const [];

    final isGroup = _groupRoomCache.containsKey(trimmedId);
    if (isGroup) {
      final groupMessages = await _fetchGroupMessages(trimmedId);
      final local = _sentMessages
          .where((m) => m.roomId == trimmedId)
          .toList(growable: false);
      final merged = <String, ChatMessageModel>{
        for (final message in groupMessages) message.id: message,
        for (final message in local) message.id: message,
      }.values.toList(growable: false);
      merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return merged;
    }

    var apiMessages = _directMessagesCache[trimmedId];
    if (apiMessages == null) {
      final peerRoom = _findDirectRoomByPeerId(trimmedId);
      if (peerRoom != null) {
        apiMessages = _directMessagesCache[peerRoom.id];
      }
    }
    final resolvedConversationId = _resolveConversationId(trimmedId);
    if (resolvedConversationId != null) {
      apiMessages = await _fetchDirectThreadMessages(resolvedConversationId);
    } else if (!_directMessagesCache.containsKey(trimmedId)) {
      final hasPlaceholderPeerRoom =
          _directRoomCache.containsKey(trimmedId) ||
              _findDirectRoomByPeerId(trimmedId) != null;
      if (!hasPlaceholderPeerRoom) {
        await _fetchDirectRooms();
      }
      apiMessages = _directMessagesCache[trimmedId];
      if (apiMessages == null) {
        final peerRoom = _findDirectRoomByPeerId(trimmedId);
        if (peerRoom != null) {
          apiMessages = await _fetchDirectThreadMessages(peerRoom.id);
        }
      }
    }

    final local = _sentMessages
        .where((m) => m.roomId == trimmedId || m.roomId == roomId)
        .toList(growable: false);
    final merged = <String, ChatMessageModel>{
      for (final message in apiMessages ?? const <ChatMessageModel>[])
        message.id: message,
      for (final message in local) message.id: message,
    }.values.toList(growable: false);
    merged.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  @override
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    final trimmedId = roomId.trim();
    if (trimmedId.isEmpty) return;

    final cachedGroup = _groupRoomCache[trimmedId];
    if (cachedGroup != null) {
      try {
        await _dio.delete<dynamic>(
          GroupsApiEndpoint.deleteComment(trimmedId, messageId),
        );
      } on DioException catch (e) {
        throw ApiErrorMapper.authExceptionFrom(e);
      }
      return;
    }
    // Note: DMs deletion is not yet supported by standard API. We can just ignore for DMs.
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String content,
    String? attachmentPath,
    String? attachmentName,
    MediaUploadKind? attachmentKind,
  }) async {
    final now = DateTime.now();
    final message = ChatMessageModel(
      id: 'local-${now.millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'me',
      senderName: 'You',
      content: content,
      createdAt: now,
      isMine: true,
      attachmentPath: attachmentPath,
      attachmentKind: attachmentKind,
      attachmentName: attachmentName,
    );
    _sentMessages.add(message);

    _roomPreviews[roomId] = _RoomPreview(
      lastMessage: _previewForMessage(content, attachmentKind, attachmentName),
      lastSenderName: 'You',
      updatedAt: now,
    );

    return message;
  }

  @override
  Future<String> uploadAttachment(String filePath, {bool isGroup = false}) async {
    final trimmedPath = filePath.trim();
    if (trimmedPath.isEmpty) {
      throw const AuthException('Attachment path is required.');
    }

    try {
      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(trimmedPath),
      });

      final url = isGroup ? GroupsApiEndpoint.media : MessagingApiEndpoint.media;
      
      final response = await _dio.post<dynamic>(url, data: formData);
      final data = response.data['data'] as Map<String, dynamic>;
      return data['mediaUrl'] as String;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  ChatRoomModel? _findDirectRoomByPeerId(String peerUserId) {
    for (final room in _directRoomCache.values) {
      if (room.peerUserId == peerUserId) return room;
    }
    return null;
  }

  String? _resolveConversationId(String roomId) {
    final cached = _directRoomCache[roomId];
    if (cached != null && cached.isDirect) {
      final peerId = cached.peerUserId;
      if (peerId != null && peerId.isNotEmpty && cached.id != peerId) {
        return cached.id;
      }
    }
    if (_directMessagesCache.containsKey(roomId) ||
        _directConversationCache.containsKey(roomId)) {
      return roomId;
    }
    final peerRoom = _findDirectRoomByPeerId(roomId);
    if (peerRoom != null &&
        peerRoom.peerUserId != null &&
        peerRoom.id != peerRoom.peerUserId) {
      return peerRoom.id;
    }
    return null;
  }

  ChatRoomModel _applyPreview(ChatRoomModel room) {
    final preview = _roomPreviews[room.id];
    if (preview == null) return room;

    return ChatRoomModel(
      id: room.id,
      title: room.title,
      type: room.type,
      avatarUrl: room.avatarUrl,
      peerUserId: room.peerUserId,
      directParticipants: room.directParticipants,
      lastMessage: preview.lastMessage,
      lastSenderName: preview.lastSenderName ?? room.lastSenderName,
      timestampLabel: _formatListTimestamp(preview.updatedAt),
      updatedAt: preview.updatedAt,
      unreadCount: 0,
      isMuted: room.isMuted,
      isOnline: room.isOnline,
      hasUnreadDot: false,
      initials: room.initials,
      statusSubtitle: room.statusSubtitle,
      isPrivate: room.isPrivate,
      memberCount: room.memberCount,
    );
  }

  @override
  Future<List<GroupModeratorCandidate>> getModeratorCandidates() async {
    try {
      final response = await _dio.get<dynamic>(
        UsersApiEndpoint.search,
        queryParameters: const {'page': 1, 'limit': 50},
      );
      final parsed = ApiListResponse.parse(
        response.data,
        UserSearchApiDto.fromJson,
      );

      return parsed.data
          .where((dto) => dto.id.isNotEmpty)
          .map(
            (dto) => GroupModeratorCandidate(
              id: dto.id,
              name: dto.fullName.trim().isNotEmpty
                  ? dto.fullName.trim()
                  : 'User',
              role: 'Member',
              avatarUrl: dto.avatarUrl,
            ),
          )
          .toList(growable: false);
    } on DioException catch (e) {
      FaithLogger.w('ChatRemote', 'moderator search failed: ${e.message}');
      return const [];
    }
  }

  @override
  Future<String> createGroup(NewGroupDraft draft) async {
    final payload = CreateGroupMapper.fromDraft(draft);

    if (payload.name.isEmpty) {
      throw const AuthException('Group name is required.');
    }

    try {
      final response = await _dio.post<dynamic>(
        GroupsApiEndpoint.list,
        data: await payload.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final groupId = ApiCreateResponse.parseId(response.data);
      _rememberGroupRoom(
        ChatRoomModel(
          id: groupId,
          title: payload.name,
          type: ChatRoomType.group,
          initials: payload.name.isNotEmpty
              ? payload.name[0].toUpperCase()
              : 'G',
        ),
      );
      return groupId;
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    } on FormatException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> requestGroupJoin(String groupId) async {
    final trimmedId = groupId.trim();
    if (trimmedId.isEmpty) {
      throw const AuthException('Group id is required.');
    }

    try {
      await _dio.post<dynamic>(GroupsApiEndpoint.joinRequests(trimmedId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<List<GroupJoinRequest>> fetchGroupJoinRequests(String groupId) async {
    final trimmedId = groupId.trim();
    if (trimmedId.isEmpty) return const [];

    try {
      final response = await _dio.get<dynamic>(
        GroupsApiEndpoint.joinRequests(trimmedId),
      );
      final parsed = ApiListResponse.parse(
        response.data,
        GroupJoinRequestApiDto.fromJson,
      );
      return parsed.data
          .where((dto) => dto.userId.isNotEmpty)
          .map(GroupJoinRequestMapper.fromDto)
          .toList(growable: false);
    } on DioException catch (e) {
      FaithLogger.w('ChatRemote', 'join requests list failed: ${e.message}');
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<List<GroupMember>> fetchGroupMembers(String groupId) async {
    final trimmedId = groupId.trim();
    if (trimmedId.isEmpty) return const [];

    try {
      final response = await _dio.get<dynamic>(
        GroupsApiEndpoint.members(trimmedId),
      );
      final parsed = ApiListResponse.parse(
        response.data,
        GroupMemberApiDto.fromJson,
      );
      return parsed.data
          .where((dto) => dto.userId.isNotEmpty)
          .map(GroupMemberMapper.fromDto)
          .toList(growable: false);
    } on DioException catch (e) {
      if (_isExpectedNonMemberGroupAccess(e)) {
        return const [];
      }
      FaithLogger.w('ChatRemote', 'group members list failed: ${e.message}');
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  bool _isExpectedNonMemberGroupAccess(DioException error) {
    return GroupAccessErrors.isNonMemberMessage(
      ApiErrorMapper.messageFrom(error),
    );
  }

  @override
  Future<void> approveGroupJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    await _mutateJoinRequest(
      GroupsApiEndpoint.approveJoinRequest(groupId, userId),
      action: 'approve',
    );
  }

  @override
  Future<void> rejectGroupJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    await _mutateJoinRequest(
      GroupsApiEndpoint.rejectJoinRequest(groupId, userId),
      action: 'reject',
    );
  }

  @override
  Future<void> inviteGroupMember({
    required String groupId,
    required String userId,
  }) async {
    final trimmedGroupId = groupId.trim();
    final trimmedUserId = userId.trim();
    if (trimmedGroupId.isEmpty || trimmedUserId.isEmpty) {
      throw const AuthException('Group and user are required.');
    }

    try {
      await _dio.post<dynamic>(
        GroupsApiEndpoint.inviteMember(trimmedGroupId, trimmedUserId),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> banGroupMember({
    required String groupId,
    required String userId,
  }) async {
    final trimmedGroupId = groupId.trim();
    final trimmedUserId = userId.trim();
    if (trimmedGroupId.isEmpty || trimmedUserId.isEmpty) {
      throw const AuthException('Group and user are required.');
    }

    try {
      await _dio.post<dynamic>(
        GroupsApiEndpoint.banMember(trimmedGroupId, trimmedUserId),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    final trimmedGroupId = groupId.trim();
    if (trimmedGroupId.isEmpty) {
      throw const AuthException('Group id is required.');
    }

    try {
      await _dio.post<dynamic>(GroupsApiEndpoint.leave(trimmedGroupId));
      _roomPreviews.remove(trimmedGroupId);
      _directMessagesCache.remove(trimmedGroupId);
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
  }) async {
    final trimmedGroupId = groupId.trim();
    final trimmedUserId = userId.trim();
    if (trimmedGroupId.isEmpty || trimmedUserId.isEmpty) {
      throw const AuthException('Group and user are required.');
    }

    try {
      await _dio.delete<dynamic>(
        GroupsApiEndpoint.removeMember(trimmedGroupId, trimmedUserId),
      );
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw const AuthException('User id is required.');
    }

    try {
      await _dio.post<dynamic>(MessagingApiEndpoint.blockUser(trimmedUserId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw const AuthException('User id is required.');
    }

    try {
      await _dio.delete<dynamic>(MessagingApiEndpoint.blockUser(trimmedUserId));
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  @override
  Future<List<String>> getBlockedUserIds() async {
    try {
      final response = await _dio.get<dynamic>(MessagingApiEndpoint.blocks);
      final parsed = ApiListResponse.parse(
        response.data,
        (json) {
          return (json['blockedUserId'] ?? json['userId'] ?? json['id'] ?? '').toString();
        },
      );
      return parsed.data.where((id) => id.isNotEmpty).toList();
    } on DioException catch (e) {
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  Future<void> _mutateJoinRequest(String path, {required String action}) async {
    try {
      await _dio.post<dynamic>(path);
    } on DioException catch (e) {
      FaithLogger.w('ChatRemote', 'join request $action failed: ${e.message}');
      throw ApiErrorMapper.authExceptionFrom(e);
    }
  }

  String _previewForMessage(
    String content,
    MediaUploadKind? kind,
    String? name,
  ) {
    if (content.trim().isNotEmpty) return content.trim();
    return switch (kind) {
      MediaUploadKind.image => 'Photo',
      MediaUploadKind.video => 'Video',
      _ => name?.trim().isNotEmpty == true ? name!.trim() : 'Attachment',
    };
  }

  String _formatListTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (day == today) {
      return DateFormat('h:mm a').format(dateTime);
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    }
    return DateFormat('MMM d').format(dateTime);
  }
}
