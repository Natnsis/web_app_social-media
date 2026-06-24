import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/domain/entities/chat_room.dart';
import 'package:faithconnect/features/chat/domain/entities/group_join_request.dart';
import 'package:faithconnect/features/chat/domain/entities/group_member.dart';
import 'package:faithconnect/features/chat/domain/entities/group_moderator_candidate.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_bloc.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_event.dart';
import 'package:faithconnect/features/chat/presentation/blocs/group_governance_state.dart';
import 'package:faithconnect/features/chat/presentation/widgets/chat_more_options_menu.dart';
import 'package:faithconnect/features/chat/presentation/widgets/group_detail_toolbar.dart';
import 'package:faithconnect/features/chat/presentation/widgets/group_join_request_tile.dart';
import 'package:faithconnect/features/chat/presentation/widgets/group_member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class GroupInfoSheet extends StatefulWidget {
  final ChatRoom room;
  final bool showJoinRequestAction;
  final bool showAdminActions;

  const GroupInfoSheet({
    super.key,
    required this.room,
    this.showJoinRequestAction = false,
    this.showAdminActions = true,
  });

  @override
  State<GroupInfoSheet> createState() => _GroupInfoSheetState();
}

class _GroupInfoSheetState extends State<GroupInfoSheet> {
  GroupDetailSection _section = GroupDetailSection.members;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _searchQuery) return;
    setState(() => _searchQuery = query);
  }

  void _onSectionChanged(GroupDetailSection section) {
    setState(() => _section = section);
    if (section == GroupDetailSection.search) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    } else {
      _searchFocusNode.unfocus();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  Future<void> _confirmLeave() async {
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
            'Are you sure you want to leave ${widget.room.title}?',
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
    context.read<GroupGovernanceBloc>().add(const GroupLeft());
    Navigator.of(context).pop();
  }

  Future<void> _showGroupDetailDialog() async {
    final colors = context.faithColors;
    final room = widget.room;
    final details = <String>[
      if (room.memberCount > 0) '${room.memberCount} members',
      if (room.isPrivate) 'Private group' else 'Public group',
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.cardBackground,
          title: Text(room.title, style: TextStyle(color: colors.primaryText)),
          content: Text(
            details.isEmpty ? 'Group chat' : details.join(' · '),
            style: TextStyle(color: colors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Close', style: TextStyle(color: colors.brandBlue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMoreActions() async {
    final action = await showChatMoreOptionsMenu<String>(
      context: context,
      topInset: groupDetailMoreMenuTopInset(context),
      options: const [
        ChatMoreMenuOption(
          value: 'share',
          icon: Iconsax.share,
          label: 'Share group',
        ),
        ChatMoreMenuOption(
          value: 'info',
          icon: Iconsax.info_circle,
          label: 'Group info',
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

    if (!mounted || action == null) return;
    switch (action) {
      case 'share':
        showInfo(context, 'Share group coming soon.');
      case 'info':
        await _showGroupDetailDialog();
      case 'leave':
        await _confirmLeave();
      case 'report':
        showInfo(context, 'Report submitted. Thank you.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: BlocConsumer<GroupGovernanceBloc, GroupGovernanceState>(
        listenWhen: (previous, current) =>
            current is GroupGovernanceLoaded &&
            (current.successMessage != null || current.errorMessage != null),
        listener: (context, state) {
          if (state is! GroupGovernanceLoaded) return;
          if (state.successMessage != null) {
            showSuccess(context, state.successMessage!);
          } else if (state.errorMessage != null &&
              !GroupAccessErrors.isNonMemberMessage(state.errorMessage)) {
            showError(context, state.errorMessage!);
          }
          context.read<GroupGovernanceBloc>().add(
                const GroupGovernanceMessageCleared(),
              );
        },
        builder: (context, state) {
          final loaded = state is GroupGovernanceLoaded ? state : null;
          final isLoading = state is GroupGovernanceLoading;
          final rawFailure =
              state is GroupGovernanceFailure ? state.message : null;
          final failure = GroupAccessErrors.userFacingOrNull(rawFailure);
          final previewLoaded = loaded ??
              (GroupAccessErrors.isNonMemberMessage(rawFailure)
                  ? GroupGovernanceLoaded(room: widget.room)
                  : null);

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, colors),
                GroupDetailToolbar(
                  memberCount:
                      previewLoaded?.room.memberCount ?? widget.room.memberCount,
                  selectedSection: _section,
                  showAdminActions: widget.showAdminActions,
                  onSectionChanged: _onSectionChanged,
                ),
                if (_section == GroupDetailSection.search &&
                    widget.showAdminActions)
                  GroupDetailSearchField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onClear: _clearSearch,
                  ),
                if (loaded?.isRefreshing == true)
                  LinearProgressIndicator(
                    minHeight: 2,
                    color: colors.brandBlue,
                    backgroundColor: Colors.transparent,
                  ),
                Expanded(
                  child: RefreshIndicator(
                    color: colors.brandBlue,
                    onRefresh: () async {
                      context
                          .read<GroupGovernanceBloc>()
                          .add(const GroupGovernanceRefreshed());
                      await context.read<GroupGovernanceBloc>().stream.firstWhere(
                            (s) =>
                                s is GroupGovernanceLoaded &&
                                !s.isRefreshing,
                          );
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      children: [
                        if (isLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.h),
                            child:
                                const Center(child: CircularProgressIndicator()),
                          )
                        else if (failure != null)
                          FaithEmptyState(
                            icon: Iconsax.info_circle,
                            title: 'Could not load group info',
                            subtitle: failure,
                            actionLabel: 'Retry',
                            onAction: () => context
                                .read<GroupGovernanceBloc>()
                                .add(GroupGovernanceRequested(widget.room)),
                          )
                        else if (previewLoaded != null)
                          ..._buildSectionContent(context, previewLoaded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSectionContent(
    BuildContext context,
    GroupGovernanceLoaded loaded,
  ) {
    return switch (_section) {
      GroupDetailSection.members => _buildMembersSection(context, loaded),
      GroupDetailSection.search => _buildSearchSection(context, loaded),
      GroupDetailSection.addMember => _buildAddMemberSection(context, loaded),
    };
  }

  List<Widget> _buildMembersSection(
    BuildContext context,
    GroupGovernanceLoaded loaded,
  ) {
    final colors = context.faithColors;
    final children = <Widget>[];

    children.addAll([
      _SectionTitle(
        title: 'Members',
        trailing: '${loaded.members.isNotEmpty ? loaded.members.length : loaded.room.memberCount}',
      ),
      SizedBox(height: 8.h),
    ]);

    if (loaded.members.isEmpty) {
      children.add(
        Text(
          'No members to show yet.',
          style: GoogleFonts.inter(color: colors.mutedText, fontSize: 14.sp),
        ),
      );
    } else {
      children.addAll(
        loaded.members.map((member) => GroupMemberTile(
              member: member,
              onRemove: widget.showAdminActions
                  ? () => context
                      .read<GroupGovernanceBloc>()
                      .add(GroupMemberRemoved(member.userId))
                  : null,
              onBan: widget.showAdminActions
                  ? () => context
                      .read<GroupGovernanceBloc>()
                      .add(GroupMemberBanned(member.userId))
                  : null,
            )),
      );
    }

    if (widget.showJoinRequestAction) {
      children.addAll([
        SizedBox(height: 20.h),
        _SectionTitle(title: 'Join this group'),
        SizedBox(height: 8.h),
        if (loaded.joinRequestSent)
          AppSurfaceCard(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Icon(Iconsax.tick_circle, color: colors.brandBlue, size: 20.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Your join request is pending admin approval.',
                    style: GoogleFonts.inter(
                      color: colors.primaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          PrimaryButton.feedAction(
            text: 'Request to Join',
            onPressed: loaded.isActionInProgress
                ? null
                : () => context
                    .read<GroupGovernanceBloc>()
                    .add(const GroupJoinRequested()),
            isLoading: loaded.isActionInProgress,
          ),
      ]);
    }

    if (widget.showAdminActions) {
      children.addAll([
        SizedBox(height: 20.h),
        _SectionTitle(
          title: 'Pending join requests',
          trailing: '${loaded.pendingRequests.length}',
        ),
        SizedBox(height: 8.h),
        if (loaded.pendingRequests.isEmpty)
          Text(
            'No pending requests right now.',
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 14.sp,
            ),
          )
        else
          ...loaded.pendingRequests.map(
            (request) => GroupJoinRequestTile(
              request: request,
              isBusy: loaded.isActionInProgress,
              onApprove: () => context.read<GroupGovernanceBloc>().add(
                    GroupJoinRequestApproved(request.userId),
                  ),
              onReject: () => context.read<GroupGovernanceBloc>().add(
                    GroupJoinRequestRejected(request.userId),
                  ),
            ),
          ),
      ]);
    }

    return children;
  }

  List<Widget> _buildSearchSection(
    BuildContext context,
    GroupGovernanceLoaded loaded,
  ) {
    final colors = context.faithColors;
    final members = _filterMembers(loaded.members);
    final candidates = _filterCandidates(loaded.inviteCandidates);
    final requests = _filterRequests(loaded.pendingRequests);

    if (_searchQuery.isEmpty) {
      return [
        Text(
          'Search members, pending requests, or people to invite.',
          style: GoogleFonts.inter(color: colors.mutedText, fontSize: 14.sp),
        ),
      ];
    }

    if (members.isEmpty && candidates.isEmpty && requests.isEmpty) {
      return [
        Text(
          'No matches for "$_searchQuery".',
          style: GoogleFonts.inter(color: colors.mutedText, fontSize: 14.sp),
        ),
      ];
    }

    final children = <Widget>[];

    if (members.isNotEmpty) {
      children.addAll([
        _SectionTitle(title: 'Members', trailing: '${members.length}'),
        SizedBox(height: 8.h),
        ...members.map((member) => GroupMemberTile(
              member: member,
              onRemove: widget.showAdminActions
                  ? () => context
                      .read<GroupGovernanceBloc>()
                      .add(GroupMemberRemoved(member.userId))
                  : null,
              onBan: widget.showAdminActions
                  ? () => context
                      .read<GroupGovernanceBloc>()
                      .add(GroupMemberBanned(member.userId))
                  : null,
            )),
        SizedBox(height: 16.h),
      ]);
    }

    if (requests.isNotEmpty) {
      children.addAll([
        _SectionTitle(title: 'Pending requests', trailing: '${requests.length}'),
        SizedBox(height: 8.h),
        ...requests.map(
          (request) => GroupJoinRequestTile(
            request: request,
            isBusy: loaded.isActionInProgress,
            onApprove: () => context.read<GroupGovernanceBloc>().add(
                  GroupJoinRequestApproved(request.userId),
                ),
            onReject: () => context.read<GroupGovernanceBloc>().add(
                  GroupJoinRequestRejected(request.userId),
                ),
          ),
        ),
        SizedBox(height: 16.h),
      ]);
    }

    if (candidates.isNotEmpty) {
      children.addAll([
        _SectionTitle(title: 'People to invite', trailing: '${candidates.length}'),
        SizedBox(height: 8.h),
        ...candidates.map(
          (candidate) => _InviteCandidateTile(
            candidate: candidate,
            isBusy: loaded.isActionInProgress,
            onInvite: () => context.read<GroupGovernanceBloc>().add(
                  GroupMemberInvited(candidate.id),
                ),
          ),
        ),
      ]);
    }

    return children;
  }

  List<Widget> _buildAddMemberSection(
    BuildContext context,
    GroupGovernanceLoaded loaded,
  ) {
    final colors = context.faithColors;

    return [
      _SectionTitle(title: 'Invite member'),
      SizedBox(height: 8.h),
      if (loaded.inviteCandidates.isEmpty)
        Text(
          'No users available to invite.',
          style: GoogleFonts.inter(color: colors.mutedText, fontSize: 14.sp),
        )
      else
        ...loaded.inviteCandidates.map(
          (candidate) => _InviteCandidateTile(
            candidate: candidate,
            isBusy: loaded.isActionInProgress,
            onInvite: () => context.read<GroupGovernanceBloc>().add(
                  GroupMemberInvited(candidate.id),
                ),
          ),
        ),
    ];
  }

  List<GroupMember> _filterMembers(List<GroupMember> members) {
    if (_searchQuery.isEmpty) return members;
    return members
        .where((m) => m.name.toLowerCase().contains(_searchQuery))
        .toList(growable: false);
  }

  List<GroupModeratorCandidate> _filterCandidates(
    List<GroupModeratorCandidate> candidates,
  ) {
    if (_searchQuery.isEmpty) return candidates;
    return candidates
        .where((c) => c.name.toLowerCase().contains(_searchQuery))
        .toList(growable: false);
  }

  List<GroupJoinRequest> _filterRequests(List<GroupJoinRequest> requests) {
    if (_searchQuery.isEmpty) return requests;
    return requests
        .where((r) => r.userName.toLowerCase().contains(_searchQuery))
        .toList(growable: false);
  }

  Widget _buildAppBar(BuildContext context, FaithAppColors colors) {
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
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showGroupDetailDialog,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      AppAvatar(
                        imageUrl: widget.room.avatarUrl,
                        initials: widget.room.initials ??
                            (widget.room.title.isNotEmpty
                                ? widget.room.title[0]
                                : 'G'),
                        size: 40,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.room.title,
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
                              _subtitle(widget.room),
                              style: GoogleFonts.inter(
                                color: colors.mutedText,
                                fontSize: 12.sp,
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
            icon: Icon(
              Icons.more_horiz,
              color: colors.iconPrimary,
              size: 26.r,
            ),
            onPressed: _showMoreActions,
          ),
        ],
      ),
    );
  }

  static String _subtitle(ChatRoom room) {
    final parts = <String>[];
    if (room.memberCount > 0) {
      parts.add('${room.memberCount} members');
    }
    if (room.isPrivate) parts.add('Private');
    return parts.isEmpty ? 'Group chat' : parts.join(' · ');
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colors.tagBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              trailing!,
              style: GoogleFonts.inter(
                color: colors.brandBlue,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InviteCandidateTile extends StatelessWidget {
  final GroupModeratorCandidate candidate;
  final bool isBusy;
  final VoidCallback? onInvite;

  const _InviteCandidateTile({
    required this.candidate,
    this.isBusy = false,
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppSurfaceCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: candidate.avatarUrl,
              initials: candidate.name.isNotEmpty ? candidate.name[0] : '?',
              size: 40,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                candidate.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: isBusy ? null : onInvite,
              child: Text(
                'Invite',
                style: GoogleFonts.inter(
                  color: colors.brandBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
