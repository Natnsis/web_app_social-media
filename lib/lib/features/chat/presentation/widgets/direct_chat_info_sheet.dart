import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_more_options_menu.dart';
import 'package:faithconnect/features/chat/application/chat_service.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_event.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DirectChatInfoResult {
  final bool isMuted;
  final bool openMessages;

  const DirectChatInfoResult({
    required this.isMuted,
    this.openMessages = false,
  });
}

class DirectChatInfoSheet extends StatefulWidget {
  final ChatRoom room;
  final bool initialMuted;

  const DirectChatInfoSheet({
    super.key,
    required this.room,
    this.initialMuted = false,
  });

  @override
  State<DirectChatInfoSheet> createState() => _DirectChatInfoSheetState();
}

class _DirectChatInfoSheetState extends State<DirectChatInfoSheet> {
  late bool _isMuted;
  bool _isBlocked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.initialMuted;
    _checkBlockedStatus();
  }

  Future<void> _checkBlockedStatus() async {
    final peerId = widget.room.peerUserId;
    if (peerId == null || peerId.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await sl<ChatService>().getBlockedUserIds();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _isLoading = false),
      (blockedIds) {
        setState(() {
          _isBlocked = blockedIds.contains(peerId);
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _toggleBlockUser() async {
    final peerId = widget.room.peerUserId;
    if (peerId == null || peerId.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmationModal(
        title: _isBlocked ? 'Unblock User' : 'Block User',
        subtitle: _isBlocked
            ? 'Are you sure you want to unblock ${widget.room.title}? They will be able to message you again.'
            : 'Are you sure you want to block ${widget.room.title}? They will not be able to send you messages.',
        confirmText: _isBlocked ? 'Unblock' : 'Block',
        cancelText: 'Cancel',
        onConfirm: () {},
        onCancel: () {},
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    final result = _isBlocked
        ? await sl<ChatService>().unblockUser(peerId)
        : await sl<ChatService>().blockUser(peerId);

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        showError(context, failure.message);
      },
      (_) {
        setState(() {
          _isBlocked = !_isBlocked;
          _isLoading = false;
        });
        showSuccess(context, _isBlocked ? 'Blocked successfully' : 'Unblocked successfully');
        
        // Notify ChatBloc that block status has changed
        sl<ChatBloc>().add(ChatThreadRequested(widget.room.id, silent: true));
      },
    );
  }

  void _pop({bool openMessages = false}) {
    Navigator.of(
      context,
    ).pop(DirectChatInfoResult(isMuted: _isMuted, openMessages: openMessages));
  }

  void _showProfileInfo() {
    final subtitle =
        widget.room.statusSubtitle ??
        (widget.room.isOnline ? 'Active now' : 'Offline');
    showInfo(context, '${widget.room.title} · $subtitle');
  }

  Future<void> _showMoreActions() async {
    final action = await showChatMoreOptionsMenu<String>(
      context: context,
      topInset: directChatDetailMoreMenuTopInset(context),
      options: [
        const ChatMoreMenuOption(
          value: 'search',
          icon: Iconsax.search_normal,
          label: 'Search in chat',
        ),
        ChatMoreMenuOption(
          value: 'block',
          icon: _isBlocked ? Iconsax.user_add : Iconsax.user_minus,
          label: _isBlocked ? 'Unblock user' : 'Block user',
          isDestructive: !_isBlocked,
        ),
        const ChatMoreMenuOption(
          value: 'report',
          icon: Iconsax.flag,
          label: 'Report user',
          isDestructive: true,
        ),
      ],
    );

    if (!mounted || action == null) return;
    switch (action) {
      case 'profile':
        _showProfileInfo();
      case 'search':
        showInfo(context, 'Search in chat coming soon.');
      case 'block':
        _toggleBlockUser();
      case 'report':
        showInfo(context, 'Report submitted. Thank you.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final room = widget.room;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppBar(context, colors, room),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                    children: [
                      AppSurfaceCard(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About',
                              style: GoogleFonts.inter(
                                color: colors.primaryText,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Direct conversation with ${room.title}.',
                              style: GoogleFonts.inter(
                                color: colors.secondaryText,
                                fontSize: 14.sp,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    FaithAppColors colors,
    ChatRoom room,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: colors.iconPrimary,
              size: 22.r,
            ),
            onPressed: () => _pop(),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showProfileInfo,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      AppAvatar(
                        imageUrl: room.avatarUrl,
                        initials:
                            room.initials ??
                            (room.title.isNotEmpty ? room.title[0] : '?'),
                        size: 40,
                        showOnline: room.isOnline,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: colors.primaryText,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _statusLabel(room),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: room.isOnline
                                    ? colors.brandBlue
                                    : colors.mutedText,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Iconsax.call, color: colors.iconPrimary, size: 24.r),
            onPressed: () => showInfo(context, 'Voice calls coming soon.'),
            tooltip: 'Call',
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: colors.iconPrimary, size: 26.r),
            onPressed: _showMoreActions,
            tooltip: 'More options',
          ),
        ],
      ),
    );
  }

  static String _statusLabel(ChatRoom room) {
    final subtitle = room.statusSubtitle?.trim();
    if (subtitle != null && subtitle.isNotEmpty) return subtitle;
    return room.isOnline ? 'Active now' : 'Offline';
  }
}
