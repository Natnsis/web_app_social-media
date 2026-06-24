import 'dart:async';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room_type.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_event.dart';
import 'package:faithconnect/features/chat/presentation/blocs/chat_state.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_list_app_bar.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_list_filter_sheet.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_list_shimmer.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChatListPage extends StatefulWidget {
  final ChatRoomType initialInboxTab;

  const ChatListPage({
    super.key,
    this.initialInboxTab = ChatRoomType.direct,
  });

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  int _tabIndex = 0;
  ChatInboxFilter _inboxFilter = ChatInboxFilter.all;
  bool _searchExpanded = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialInboxTab == ChatRoomType.group ? 1 : 0;
    _searchController.addListener(_onSearchChanged);
    _loadRooms();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmupSocketsForTab());
  }

  void _warmupSocketsForTab([ChatRoomType? tab]) {
    final inboxTab = tab ?? _selectedType;
    switch (inboxTab) {
      case ChatRoomType.direct:
        sl<DirectMessagingSocketService>().ensureConnected();
      case ChatRoomType.group:
        sl<GroupChatSocketService>().ensureConnected();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void activate() {
    super.activate();
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      final state = context.read<ChatBloc>().state;
      if (state is ChatThreadLoaded ||
          state is ChatThreadLoading ||
          (state is ChatFailureState && state.roomId != null)) {
        context.read<ChatBloc>().add(const ChatListRestoreRequested());
      } else if (state is! ChatRoomsLoaded && state is! ChatListLoading) {
        _loadRooms();
      }
    }
  }

  void _applyRestoreInboxTab(ChatRoomType tab) {
    final nextIndex = tab == ChatRoomType.direct ? 0 : 1;
    if (_tabIndex != nextIndex) {
      setState(() => _tabIndex = nextIndex);
    }
  }

  List<ChatRoom> _roomsForState(ChatState state, ChatBloc bloc) {
    if (state is ChatRoomsLoaded) return state.rooms;
    if (bloc.cachedRooms.isNotEmpty) return bloc.cachedRooms;
    return const [];
  }

  void _loadRooms() {
    context.read<ChatBloc>().add(const ChatRoomsRequested());
  }

  Future<void> _refreshRooms() async {
    final bloc = context.read<ChatBloc>();
    bloc.add(const ChatRoomsRefreshed());
    await bloc.stream.firstWhere(
      (state) => state is ChatRoomsLoaded || state is ChatFailureState,
    );
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = _searchController.text);
    });
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
      if (!_searchExpanded) {
        _searchController.clear();
        _searchQuery = '';
      }
    });

    if (_searchExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    } else {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _openFilters() async {
    final selected = await showChatListFilterSheet(
      context,
      selected: _inboxFilter,
    );
    if (!mounted || selected == null || selected == _inboxFilter) return;
    setState(() => _inboxFilter = selected);
  }

  ChatRoomType get _selectedType =>
      _tabIndex == 0 ? ChatRoomType.direct : ChatRoomType.group;

  List<ChatRoom> _visibleRooms(List<ChatRoom> allRooms) {
    final query = _searchQuery.trim().toLowerCase();

    var rooms = allRooms.where((room) => room.type == _selectedType);

    if (query.isNotEmpty) {
      rooms = rooms.where((room) {
        final haystack = [
          room.title,
          room.lastMessage,
          room.lastSenderName,
        ].whereType<String>().join(' ').toLowerCase();
        return haystack.contains(query);
      });
    }

    rooms = switch (_inboxFilter) {
      ChatInboxFilter.unread =>
        rooms.where((room) => room.unreadCount > 0 || room.hasUnreadDot),
      ChatInboxFilter.muted => rooms.where((room) => room.isMuted),
      ChatInboxFilter.all => rooms,
    };

    final sorted = rooms.toList()
      ..sort(
        (a, b) =>
            (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
      );
    return sorted;
  }

  String _emptyTitle(BuildContext context) {
    if (_searchQuery.trim().isNotEmpty) {
      return context.tr('chat_list.empty_no_matches_title');
    }
    if (_inboxFilter == ChatInboxFilter.unread) {
      return context.tr('chat_list.empty_no_unread_title');
    }
    if (_inboxFilter == ChatInboxFilter.muted) {
      return context.tr('chat_list.empty_no_muted_title');
    }
    return _tabIndex == 0
        ? context.tr('chat_list.empty_no_direct_title')
        : context.tr('chat_list.empty_no_groups_title');
  }

  String _emptySubtitle(BuildContext context) {
    if (_searchQuery.trim().isNotEmpty) {
      return context.tr('chat_list.empty_search_subtitle');
    }
    if (_inboxFilter != ChatInboxFilter.all) {
      return context.tr('chat_list.empty_filter_subtitle');
    }
    return _tabIndex == 0
        ? context.tr('chat_list.empty_direct_subtitle')
        : context.tr('chat_list.empty_groups_subtitle');
  }

  Future<void> _openAddUser() => context.pushNamed(RoutesConstant.chatAddUser);

  Future<void> _openCreateGroup() async {
    await context.pushNamed(RoutesConstant.newGroup);
    if (!context.mounted) return;
    _loadRooms();
  }

  Widget? _buildFloatingActionButton(bool showCreateGroup) {
    if (_tabIndex == 0) {
      return FaithFab.mini(
        heroTag: 'fab_chat_add_user',
        onPressed: _openAddUser,
        child: Icon(Iconsax.user_add, size: 20.r),
      );
    }

    if (!showCreateGroup) return null;

    return FaithFab.mini(
      heroTag: 'fab_chat_create_group',
      onPressed: _openCreateGroup,
      child: Icon(Iconsax.add, size: 20.r),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final filterActive = _inboxFilter != ChatInboxFilter.all;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          current is ChatRoomsLoaded && current.restoreInboxTab != null,
      listener: (context, state) {
        if (state is ChatRoomsLoaded && state.restoreInboxTab != null) {
          _applyRestoreInboxTab(state.restoreInboxTab!);
          _warmupSocketsForTab(state.restoreInboxTab!);
        }
      },
      child: RoleGuardBuilder(
        builder: (context, access) {
          final showCreateGroup = access.showCreateActions;

          return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: ChatListAppBar(
        onSearchTap: _toggleSearch,
        onFilterTap: _openFilters,
        filterActive: filterActive,
        searchActive: _searchExpanded,
      ),
      floatingActionButton: _buildFloatingActionButton(showCreateGroup),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_searchExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 15.sp,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('chat_list.search_chats'),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    size: 20.r,
                    color: colors.mutedText,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20.r,
                            color: colors.mutedText,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.tagBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: colors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: colors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: colors.brandBlue),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
            child: SegmentedPillControl(
              labels: [
                context.tr('chat_list.tab_direct'),
                context.tr('chat_list.tab_groups'),
              ],
              selectedIndex: _tabIndex,
              onChanged: (index) {
                setState(() => _tabIndex = index);
                _warmupSocketsForTab(
                  index == 0 ? ChatRoomType.direct : ChatRoomType.group,
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final bloc = context.read<ChatBloc>();

                if (state is ChatListLoading) {
                  return const ChatListShimmer();
                }

                if (state is ChatFailureState && state.roomId == null) {
                  return RefreshIndicator(
                    color: colors.brandBlue,
                    onRefresh: _refreshRooms,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        FaithEmptyState(
                          icon: Iconsax.warning_2,
                          title: context.tr('chat_list.error_load_title'),
                          subtitle: state.message,
                          actionLabel: context.tr('chat_list.try_again'),
                          onAction: _loadRooms,
                        ),
                      ],
                    ),
                  );
                }

                final allRooms = _roomsForState(state, bloc);
                if (allRooms.isNotEmpty ||
                    state is ChatRoomsLoaded ||
                    state is ChatThreadLoaded ||
                    state is ChatThreadLoading) {
                  final rooms = _visibleRooms(allRooms);

                  if (rooms.isEmpty) {
                    return RefreshIndicator(
                      color: colors.brandBlue,
                      onRefresh: _refreshRooms,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          FaithEmptyState(
                            icon: _tabIndex == 0
                                ? Iconsax.message
                                : Iconsax.people,
                            title: _emptyTitle(context),
                            subtitle: _emptySubtitle(context),
                            actionLabel: _tabIndex == 0 &&
                                    _searchQuery.isEmpty &&
                                    _inboxFilter == ChatInboxFilter.all
                                ? context.tr('chat_list.add_user')
                                : showCreateGroup &&
                                        _tabIndex == 1 &&
                                        _searchQuery.isEmpty &&
                                        _inboxFilter == ChatInboxFilter.all
                                    ? context.tr('chat_list.create_group')
                                    : null,
                            onAction: _tabIndex == 0 &&
                                    _searchQuery.isEmpty &&
                                    _inboxFilter == ChatInboxFilter.all
                                ? _openAddUser
                                : showCreateGroup &&
                                        _tabIndex == 1 &&
                                        _searchQuery.isEmpty &&
                                        _inboxFilter == ChatInboxFilter.all
                                    ? _openCreateGroup
                                    : null,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: colors.brandBlue,
                    onRefresh: _refreshRooms,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 88.h),
                      itemCount: rooms.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return ChatListTile(
                          room: room,
                          onTap: () => context.pushNamed(
                            RoutesConstant.chatDetail,
                            pathParameters: {'id': room.id},
                            extra: room.type,
                          ),
                        );
                      },
                    ),
                  );
                }

                if (state is ChatFailureState && state.roomId != null) {
                  return const ChatListShimmer();
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
          );
        },
      ),
    );
  }
}
