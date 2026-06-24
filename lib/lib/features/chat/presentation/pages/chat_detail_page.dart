import 'dart:async';
import 'dart:io';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_message.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';
import 'package:faithconnect/features/chat/application/chat_service.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_event.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_state.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_conversation_background.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_date_separator.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_detail_app_bar.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_more_options_menu.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_message_input_bar.dart';
import 'package:faithconnect/features/chat/presentation/navigation/direct_chat_navigation.dart';
import 'package:faithconnect/features/chat/presentation/navigation/group_governance_navigation.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatDetailPage extends StatefulWidget {
  final String roomId;
  final ChatRoomType? roomType;

  const ChatDetailPage({
    super.key,
    required this.roomId,
    this.roomType,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

enum _ChatAttachAction { photo, video }

class _ChatDetailPageState extends State<ChatDetailPage> {
  late final ChatBloc _chatBloc;
  final _messageController = TextEditingController();
  final _composerFocusNode = FocusNode();
  final _scrollController = ScrollController();
  int _lastMessageCount = 0;
  UploadedMedia? _pendingAttachment;
  Timer? _typingStopTimer;
  bool _isTypingEmitted = false;
  bool _threadLeft = false;
  ChatMessage? _replyingToMessage;
  ChatMessage? _editingMessage;
  bool? _directMuteOverride;
  bool _joinRequestSending = false;
  bool _joinRequestSent = false;
  bool _initialSetupComplete = false;
  bool _isPeerBlocked = false;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _connectSocketForThread();
    _chatBloc.add(ChatThreadRequested(widget.roomId));
    _chatBloc.add(
      ChatMessagingThreadOpened(widget.roomId, roomType: widget.roomType),
    );
    _messageController.addListener(_onComposerChanged);
  }

  void _connectSocketForThread() {
    final type = widget.roomType ?? _resolveCachedRoomType();
    switch (type) {
      case ChatRoomType.group:
        sl<GroupChatSocketService>().ensureConnected();
      case ChatRoomType.direct:
        sl<DirectMessagingSocketService>().ensureConnected();
      case null:
        break;
    }
  }

  ChatRoomType? _resolveCachedRoomType() {
    final state = _chatBloc.state;
    if (state is ChatThreadLoaded && state.room.id == widget.roomId) {
      return state.room.type;
    }
    for (final room in _chatBloc.cachedRooms) {
      if (room.id == widget.roomId) return room.type;
    }
    return null;
  }

  @override
  void dispose() {
    _typingStopTimer?.cancel();
    _messageController.removeListener(_onComposerChanged);
    _closeMessagingThread();
    _messageController.dispose();
    _composerFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _closeMessagingThread() {
    if (_threadLeft) return;
    _threadLeft = true;
    if (_isTypingEmitted) {
      _isTypingEmitted = false;
      _chatBloc.add(ChatTypingStopped(widget.roomId));
    }
    _chatBloc.add(ChatMessagingThreadClosed(widget.roomId));
  }

  ChatRoomType? _roomTypeForRestore() {
    final state = _chatBloc.state;
    if (state is ChatThreadLoaded && state.room.id == widget.roomId) {
      return state.room.type;
    }
    for (final room in _chatBloc.cachedRooms) {
      if (room.id == widget.roomId) return room.type;
    }
    return null;
  }

  void _onComposerChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (!hasText) {
      _stopTyping();
      return;
    }

    if (!_isTypingEmitted) {
      _isTypingEmitted = true;
      _chatBloc.add(ChatTypingStarted(widget.roomId));
    }

    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 2), _stopTyping);
  }

  void _stopTyping() {
    _typingStopTimer?.cancel();
    if (!_isTypingEmitted) return;
    _isTypingEmitted = false;
    if (!mounted) return;
    _chatBloc.add(ChatTypingStopped(widget.roomId));
  }

  String? get _pendingAttachmentName {
    final media = _pendingAttachment;
    if (media == null) return null;
    final name = media.filePath.split(Platform.pathSeparator).last;
    if (name.isNotEmpty) return name;
    return media.kind == MediaUploadKind.video ? 'Video' : 'Photo';
  }

  void _clearAttachment() {
    setState(() => _pendingAttachment = null);
  }

  Future<void> _pickAttachment() async {
    final colors = context.faithColors;
    final action = await showModalBottomSheet<_ChatAttachAction>(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.mutedText.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Attach',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: Icon(Iconsax.gallery, color: colors.brandBlue),
                  title: Text(
                    'Photo',
                    style: TextStyle(color: colors.primaryText),
                  ),
                  onTap: () =>
                      Navigator.pop(sheetContext, _ChatAttachAction.photo),
                ),
                ListTile(
                  leading: Icon(Iconsax.video, color: colors.brandBlue),
                  title: Text(
                    'Video',
                    style: TextStyle(color: colors.primaryText),
                  ),
                  onTap: () =>
                      Navigator.pop(sheetContext, _ChatAttachAction.video),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    final service = sl<MediaUploadService>();
    final picked = switch (action) {
      _ChatAttachAction.photo => await service.pickImage(),
      _ChatAttachAction.video => await service.pickVideo(),
    };

    if (!mounted || picked == null) return;
    setState(() => _pendingAttachment = picked);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    final attachment = _pendingAttachment;
    if (content.isEmpty && attachment == null) return;

    final bloc = context.read<ChatBloc>();
    final state = bloc.state;
    if (state is ChatThreadLoaded && state.isSending) return;

    // Just dispatch the message; ChatBloc handles the upload and socket emit.
    await _dispatchMessage(
      content,
      attachment?.filePath,
      attachment?.kind,
      _pendingAttachmentName,
    );
  }

  Future<void> _dispatchMessage(String content, String? attachmentPath, MediaUploadKind? kind, String? name) async {
    final bloc = context.read<ChatBloc>();
    if (_editingMessage != null) {
      bloc.add(ChatMessageEditSent(
        roomId: widget.roomId,
        messageId: _editingMessage!.id,
        content: content,
      ));
      setState(() => _editingMessage = null);
    } else if (_replyingToMessage != null) {
      bloc.add(ChatReplySent(
        roomId: widget.roomId,
        replyToId: _replyingToMessage!.id,
        content: content,
        attachmentPath: attachmentPath,
        attachmentKind: kind,
        attachmentName: name,
      ));
      setState(() => _replyingToMessage = null);
    } else {
      bloc.add(ChatMessageSent(
        roomId: widget.roomId,
        content: content,
        attachmentPath: attachmentPath,
        attachmentKind: kind,
        attachmentName: name,
      ));
    }
    _messageController.clear();
    _clearAttachment();
    _stopTyping();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (!_scrollController.position.hasContentDimensions) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _retryLoad() {
    context.read<ChatBloc>().add(ChatThreadRequested(widget.roomId));
  }

  void _onLeaveThread() {
    _chatBloc.add(ChatListRestoreRequested(inboxTab: _roomTypeForRestore()));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _onLeaveThread();
      },
      child: Scaffold(
      backgroundColor: context.faithColors.scaffoldBackground,
      body: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (previous, current) {
          if (current is ChatThreadLoaded &&
              current.room.id == widget.roomId) {
            final prevLoaded = previous is ChatThreadLoaded && previous.room.id == widget.roomId;
            final prevConnected = prevLoaded ? previous.isSocketConnected : null;
            if (current.sendErrorMessage != null ||
                current.messages.length != _lastMessageCount ||
                current.isPeerTyping ||
                current.isSocketConnected != prevConnected ||
                (!_initialSetupComplete && !current.isRefreshing)) {
              return true;
            }
          }
          return false;
        },
        listener: (context, state) {
          if (state is! ChatThreadLoaded || state.room.id != widget.roomId) {
            return;
          }

          if (!_initialSetupComplete && !state.isRefreshing) {
            setState(() {
              _initialSetupComplete = true;
            });
            if (state.room.isDirect) {
              _checkBlockedStatus(room: state.room);
            }
          }

          if (state.sendErrorMessage != null) {
            showError(context, state.sendErrorMessage!);
            context.read<ChatBloc>().add(const ChatSendErrorDismissed());
          }

          final shouldScroll = state.messages.length != _lastMessageCount ||
              state.isPeerTyping;
          if (shouldScroll) {
            _lastMessageCount = state.messages.length;
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is ChatFailureState && state.roomId == widget.roomId) {
            if (GroupAccessErrors.isNonMemberMessage(state.message)) {
              return _buildNonMemberGroupThread(context);
            }
            return _buildError(state.message, onRetry: _retryLoad);
          }

          if (_isThreadLoading(state)) {
            return Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top + 56.h),
                Expanded(child: _buildMessageShimmer()),
              ],
            );
          }

          if (state is ChatThreadLoaded && state.room.id == widget.roomId) {
            return _buildThread(state);
          }

          if (state is ChatFailureState) {
            if (GroupAccessErrors.isNonMemberMessage(state.message)) {
              return _buildNonMemberGroupThread(context);
            }
            return _buildError(state.message, onRetry: _retryLoad);
          }

          return Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 56.h),
              Expanded(child: _buildMessageShimmer()),
            ],
          );
        },
      ),
    ),
    );
  }

  bool _isThreadLoading(ChatState state) {
    if (state is ChatThreadLoading && state.roomId == widget.roomId) {
      return true;
    }
    if (state is ChatThreadLoaded) {
      if (state.room.id != widget.roomId) return true;
      if (!_initialSetupComplete) {
        return state.isRefreshing;
      }
      return state.isRefreshing && state.messages.isEmpty;
    }
    return true;
  }

  Widget _buildThread(ChatThreadLoaded state) {
    final isGroup = state.room.type == ChatRoomType.group;
    final entries = buildChatThreadList(
      state.messages,
      isGroup: isGroup,
    );

    final listChildren = <Widget>[];
    for (final entry in entries) {
      switch (entry) {
        case ChatThreadDateEntry(:final label):
          listChildren.add(ChatDateSeparator(label: label));
        case ChatThreadMessageEntry(:final layout):
          final isMine = layout.message.isMine;

          listChildren.add(
            _MessageSeenReporter(
              roomId: state.room.id,
              messageId: layout.message.id,
              isGroup: isGroup,
              isMine: isMine,
              child: Padding(
                padding: EdgeInsets.only(
                  top: layout.isFirstInGroup ? 6.h : 2.h,
                  bottom: layout.isLastInGroup ? 6.h : 2.h,
                  left: isMine ? 48.w : 6.w,
                  right: isMine ? 6.w : 48.w,
                ),
                child: ChatMessageBubble(
                  layout: layout,
                  roomType: state.room.type,
                  peerAvatarUrl: state.room.isDirect ? state.room.avatarUrl : null,
                  onLongPress: (msg, pos) => _showActionMenu(context, msg, pos),
                ),
              ),
            ),
          );
      }
    }

    return Column(
      children: [
        ChatDetailAppBar(
          room: state.room,
          onBack: () => context.pop(),
          onTitleTap: state.room.isGroup
              ? () => GroupGovernanceNavigation.showGroupInfoSheet(
                    context,
                    room: state.room,
                  )
              : () => _openDirectInfoSheet(state.room),
          onMoreTap: state.room.isGroup
              ? () => _showGroupMoreDialog(context, state.room)
              : null,
        ),
        if (state.isRefreshing)
          LinearProgressIndicator(
            minHeight: 2,
            color: context.faithColors.brandBlue,
            backgroundColor: Colors.transparent,
          ),
        if (!state.isSocketConnected) _buildReconnectingBanner(context),
        Expanded(
          child: ChatConversationBackground(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      isGroup
                          ? 'No messages yet.\nSend the first message to start the group chat.'
                          : 'No messages yet.\nSay hello!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.faithColors.mutedText,
                          ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 12.h),
                    itemCount: listChildren.length,
                    itemBuilder: (context, index) {
                      return listChildren[index];
                    },
                  ),
          ),
        ),
        if (state.typingUserIds.isNotEmpty)
          ...state.typingUserIds.map((id) => ChatTypingIndicator(key: ValueKey('typing_$id')))
        else if (state.isPeerTyping)
          const ChatTypingIndicator(),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _replyingToMessage != null
              ? _buildReplyPreview()
              : _editingMessage != null
                  ? _buildEditPreview()
                  : const SizedBox.shrink(),
        ),
        _isPeerBlocked
            ? _buildBlockedBanner()
            : ChatMessageInputBar(
                controller: _messageController,
                focusNode: _composerFocusNode,
                onSend: _sendMessage,
                onSubmitted: (_) => _sendMessage(),
                isSending: state.isSending,
                onAttach: _pickAttachment,
                attachmentName: _pendingAttachmentName,
                onAttachmentRemove: _clearAttachment,
              ),
      ],
    );
  }

  Widget _buildReconnectingBanner(BuildContext context) {
    final colors = context.faithColors;
    return Material(
      color: colors.brandBlue.withValues(alpha: 0.12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 14.r,
              height: 14.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.brandBlue,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Reconnecting to chat…',
                style: GoogleFonts.inter(
                  color: colors.brandBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            AppSpacing.v16,
            PrimaryButton(
              text: 'Retry',
              onPressed: onRetry,
              width: 160.w,
            ),
          ],
        ),
      ),
    );
  }

  ChatRoom? _roomForPage() {
    for (final room in _chatBloc.cachedRooms) {
      if (room.id == widget.roomId) return room;
    }
    final state = _chatBloc.state;
    if (state is ChatThreadLoaded && state.room.id == widget.roomId) {
      return state.room;
    }
    if (widget.roomType == ChatRoomType.group) {
      return ChatRoom(
        id: widget.roomId,
        title: 'Group',
        type: ChatRoomType.group,
      );
    }
    return null;
  }

  Future<void> _openGroupJoinSheet(ChatRoom room) {
    return GroupGovernanceNavigation.showGroupInfoSheet(
      context,
      room: room,
      showJoinRequestAction: true,
    );
  }

  Future<void> _sendJoinRequest(String groupId) async {
    if (_joinRequestSending || _joinRequestSent) return;
    setState(() => _joinRequestSending = true);

    final result = await sl<ChatService>().requestGroupJoin(groupId);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _joinRequestSending = false);
        showError(context, failure.message);
      },
      (_) {
        setState(() {
          _joinRequestSending = false;
          _joinRequestSent = true;
        });
        showSuccess(context, 'Join request sent. An admin will review it soon.');
      },
    );
  }

  Widget _buildNonMemberGroupThread(BuildContext context) {
    final room = _roomForPage();
    final colors = context.faithColors;

    if (room == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Text(
              'Join this group to view messages.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.mutedText),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ChatDetailAppBar(
          room: room,
          onBack: () => context.pop(),
          onTitleTap: () => _openGroupJoinSheet(room),
        ),
        Expanded(
          child: ChatConversationBackground(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        color: colors.tagBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.divider.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Icon(
                        Iconsax.lock,
                        size: 36.r,
                        color: colors.mutedText,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Members only',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'You need to be a member to view\nmessages in this group.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: colors.mutedText,
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    if (_joinRequestSent)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.brandBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: colors.brandBlue.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.tick_circle,
                              color: colors.brandBlue,
                              size: 20.r,
                            ),
                            SizedBox(width: 10.w),
                            Flexible(
                              child: Text(
                                'Request sent — waiting for admin approval.',
                                style: GoogleFonts.inter(
                                  color: colors.primaryText,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      PrimaryButton.feedAction(
                        text: 'Request to Join',
                        width: 200.w,
                        onPressed: _joinRequestSending
                            ? null
                            : () => _sendJoinRequest(room.id),
                        isLoading: _joinRequestSending,
                        icon: Icon(
                          Iconsax.user_add,
                          color: Colors.white,
                          size: 18.r,
                        ),
                      ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () => _openGroupJoinSheet(room),
                      child: Text(
                        'View group details',
                        style: GoogleFonts.inter(
                          color: colors.brandBlue,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageShimmer() {
    final fill = faithShimmerFill(context);
    final colors = context.faithColors;

    return ChatConversationBackground(
      child: FaithShimmer(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          itemCount: 8,
          itemBuilder: (context, index) {
            final alignRight = index.isOdd;
            final widthFactor = alignRight ? 0.58 : 0.68;

            return Padding(
              padding: EdgeInsets.only(
                top: index % 2 == 0 ? 8.h : 2.h,
                bottom: 2.h,
              ),
              child: Align(
                alignment:
                    alignRight ? Alignment.centerRight : Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!alignRight) ...[
                      SizedBox(width: 36.r, height: 32.r),
                      SizedBox(width: 6.w),
                    ],
                    Container(
                      width: MediaQuery.sizeOf(context).width * widthFactor,
                      height: (44 + (index % 3) * 12).h,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(alignRight ? 16.r : 4.r),
                          bottomRight: Radius.circular(alignRight ? 4.r : 16.r),
                        ),
                        border: context.isDarkMode
                            ? null
                            : Border.all(color: colors.divider),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isDirectMuted(ChatRoom room) =>
      _directMuteOverride ?? room.isMuted;

  Future<void> _openDirectInfoSheet(ChatRoom room) async {
    final result = await DirectChatNavigation.showInfoSheet(
      context,
      room: room,
      isMuted: _isDirectMuted(room),
    );
    _checkBlockedStatus(room: room);
    if (!mounted || result == null) return;

    setState(() => _directMuteOverride = result.isMuted);
    if (result.openMessages) {
      _scrollToLatestMessage();
    }
  }

  Future<void> _checkBlockedStatus({ChatRoom? room}) async {
    final resolvedRoom = room ?? _roomForPage();
    if (resolvedRoom == null || !resolvedRoom.isDirect) return;

    final peerId = resolvedRoom.peerUserId?.trim();
    if (peerId == null || peerId.isEmpty) return;

    final result = await sl<ChatService>().getBlockedUserIds();
    if (!mounted) return;
    result.fold(
      (_) {},
      (blockedIds) {
        if (!mounted) return;
        setState(() {
          _isPeerBlocked = blockedIds.contains(peerId);
        });
      },
    );
  }

  Widget _buildBlockedBanner() {
    final colors = context.faithColors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(
          top: BorderSide(color: colors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(
              Iconsax.info_circle,
              color: colors.mutedText,
              size: 20.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'You have blocked this user.',
                style: GoogleFonts.inter(
                  color: colors.mutedText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _unblockPeerUser,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                backgroundColor: colors.brandBlue.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Unblock',
                style: GoogleFonts.inter(
                  color: colors.brandBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unblockPeerUser() async {
    final room = _roomForPage();
    if (room == null) return;

    final peerId = room.peerUserId;
    if (peerId == null || peerId.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmationModal(
        title: 'Unblock User',
        subtitle: 'Are you sure you want to unblock ${room.title}? They will be able to message you again.',
        confirmText: 'Unblock',
        cancelText: 'Cancel',
        onConfirm: () {},
        onCancel: () {},
      ),
    );

    if (confirm != true || !mounted) return;

    final result = await sl<ChatService>().unblockUser(peerId);
    result.fold(
      (failure) => showError(context, failure.message),
      (_) {
        setState(() {
          _isPeerBlocked = false;
        });
        showSuccess(context, 'Unblocked successfully');
        _chatBloc.add(ChatThreadRequested(widget.roomId, silent: true));
      },
    );
  }

  void _scrollToLatestMessage() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showGroupMoreDialog(BuildContext context, ChatRoom room) async {
    final action = await showChatMoreOptionsMenu<String>(
      context: context,
      topInset: chatDetailMoreMenuTopInset(context),
      options: const [
        ChatMoreMenuOption(
          value: 'info',
          icon: Iconsax.people,
          label: 'Group info',
        ),
        ChatMoreMenuOption(
          value: 'share',
          icon: Iconsax.share,
          label: 'Share group',
        ),
        ChatMoreMenuOption(
          value: 'leave',
          icon: Iconsax.logout,
          label: 'Leave group',
          isDestructive: true,
        ),
        ChatMoreMenuOption(
          value: 'report',
          icon: Iconsax.flag,
          label: 'Report group',
          isDestructive: true,
        ),
      ],
    );

    if (!context.mounted || action == null) return;
    switch (action) {
      case 'info':
        await GroupGovernanceNavigation.showGroupInfoSheet(
          context,
          room: room,
        );
      case 'share':
        showInfo(context, 'Share group coming soon.');
      case 'leave':
        await _confirmLeaveGroup(room);
      case 'report':
        showInfo(context, 'Report submitted. Thank you.');
    }
  }

  Future<void> _confirmLeaveGroup(ChatRoom room) async {
    final colors = context.faithColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text(
            'Leave group',
            style: TextStyle(color: colors.primaryText),
          ),
          content: Text(
            'Are you sure you want to leave ${room.title}?',
            style: TextStyle(color: colors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel', style: TextStyle(color: colors.mutedText)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) return;
    context.pop();
    showInfo(context, 'You left ${room.title}.');
  }

  void _showActionMenu(BuildContext context, ChatMessage message, Offset globalPosition) {
    HapticFeedback.mediumImpact();
    final isAdmin = sl<HomeShellModeNotifier>().canManageChurchContent;
    showChatMessageActionMenu(
      context,
      globalPosition: globalPosition,
      isMine: message.isMine,
      isAdmin: isAdmin,
      onReply: () => _beginReply(message),
      onEdit: () => _beginEdit(message),
      onDelete: () => _confirmDeleteMessage(message),
    );
  }

  void _beginReply(ChatMessage message) {
    setState(() {
      _replyingToMessage = message;
      _editingMessage = null;
    });
    _focusComposer(selectAll: false);
  }

  void _beginEdit(ChatMessage message) {
    setState(() {
      _editingMessage = message;
      _replyingToMessage = null;
      _messageController.text = message.content;
    });
    _focusComposer(selectAll: true);
  }

  void _focusComposer({required bool selectAll}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _composerFocusNode.requestFocus();
      if (selectAll) {
        _messageController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _messageController.text.length,
        );
      } else {
        _messageController.selection = TextSelection.collapsed(
          offset: _messageController.text.length,
        );
      }
      _scrollToBottom();
    });
  }

  void _confirmDeleteMessage(ChatMessage message) {
    final colors = context.faithColors;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text('Delete Message', style: TextStyle(color: colors.primaryText)),
          content: Text('Are you sure you want to delete this message?', style: TextStyle(color: colors.secondaryText)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: colors.mutedText)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _chatBloc.add(
                  ChatMessageDeleteSent(
                    roomId: widget.roomId,
                    messageId: message.id,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReplyPreview() {
    final colors = context.faithColors;
    final msg = _replyingToMessage!;

    final hasMediaUrl = msg.attachmentPath != null &&
        msg.attachmentPath!.trim().isNotEmpty &&
        (msg.attachmentPath!.startsWith('http://') ||
            msg.attachmentPath!.startsWith('https://'));

    final previewText = msg.content.trim().isNotEmpty
        ? msg.content
        : (hasMediaUrl ? '📷 Photo' : '');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.backward_5_seconds, color: colors.brandBlue, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${msg.isMine ? "yourself" : msg.senderName}',
                  style: GoogleFonts.inter(
                    color: colors.brandBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                if (hasMediaUrl)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.network(
                          msg.attachmentPath!,
                          width: 32.r,
                          height: 32.r,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported_outlined,
                            size: 20.r,
                            color: colors.mutedText,
                          ),
                        ),
                      ),
                      if (previewText.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            previewText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: colors.secondaryText,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Text(
                    previewText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: colors.secondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colors.mutedText, size: 18.r),
            onPressed: () => setState(() => _replyingToMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPreview() {
    final colors = context.faithColors;
    final msg = _editingMessage!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.edit, color: colors.brandBlue, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing message',
                  style: GoogleFonts.inter(
                    color: colors.brandBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  msg.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colors.mutedText, size: 18.r),
            onPressed: () {
              setState(() {
                _editingMessage = null;
                _messageController.clear();
              });
            },
          ),
        ],
      ),
    );
  }
}

Future<void> showChatMessageActionMenu(
  BuildContext context, {
  required Offset globalPosition,
  required bool isMine,
  bool isAdmin = false,
  required VoidCallback onReply,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) async {
  final colors = context.faithColors;
  final overlayBox =
      Overlay.of(context).context.findRenderObject()! as RenderBox;
  final screenSize = overlayBox.size;
  const menuWidth = 168.0;
  const estimatedItemHeight = 48.0;

  // Permission rules:
  // - Admin: reply / edit / delete on ANY message
  // - Standard user: edit / delete only on OWN messages, reply only on OTHERS'
  final canReply = isAdmin || !isMine;
  final canEdit = isAdmin || isMine;
  final canDelete = isAdmin || isMine;

  final showReply = canReply;
  final showEdit = canEdit && onEdit != null;
  final showDelete = canDelete && onDelete != null;

  final itemCount = (showReply ? 1 : 0) + (showEdit ? 1 : 0) + (showDelete ? 1 : 0);
  if (itemCount == 0) return;

  final menuHeight = estimatedItemHeight * itemCount;
  final left = globalPosition.dx.clamp(12.0, screenSize.width - menuWidth - 12);
  final top = (globalPosition.dy - menuHeight - 8)
      .clamp(12.0, screenSize.height - menuHeight - 12);

  final selected = await showMenu<String>(
    context: context,
    color: colors.cardBackground,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    position: RelativeRect.fromLTRB(
      left,
      top,
      left + 1,
      top + 1,
    ),
    items: [
      if (showReply)
        PopupMenuItem<String>(
          value: 'reply',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.backward_5_seconds, size: 18.r, color: colors.brandBlue),
              SizedBox(width: 10.w),
              Text('Reply', style: TextStyle(color: colors.primaryText)),
            ],
          ),
        ),
      if (showEdit)
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.edit, size: 18.r, color: colors.brandBlue),
              SizedBox(width: 10.w),
              Text('Edit', style: TextStyle(color: colors.primaryText)),
            ],
          ),
        ),
      if (showDelete)
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.trash, color: Colors.red, size: 18.r),
              SizedBox(width: 10.w),
              const Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
    ],
  );

  switch (selected) {
    case 'reply':
      onReply();
      break;
    case 'edit':
      onEdit?.call();
      break;
    case 'delete':
      onDelete?.call();
      break;
  }
}

class _MessageSeenReporter extends StatefulWidget {
  final Widget child;
  final String roomId;
  final String messageId;
  final bool isGroup;
  final bool isMine;

  const _MessageSeenReporter({
    required this.child,
    required this.roomId,
    required this.messageId,
    required this.isGroup,
    required this.isMine,
  });

  @override
  State<_MessageSeenReporter> createState() => _MessageSeenReporterState();
}

class _MessageSeenReporterState extends State<_MessageSeenReporter> {
  @override
  void initState() {
    super.initState();
    if (!widget.isMine) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ChatBloc>().add(ChatMessageSeenByMe(
            roomId: widget.roomId,
            messageId: widget.messageId,
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () {
        if (!widget.isMine) {
          context.read<ChatBloc>().add(ChatMessageSeenByMe(
            roomId: widget.roomId,
            messageId: widget.messageId,
          ));
        }
      },
      child: widget.child,
    );
  }
}
