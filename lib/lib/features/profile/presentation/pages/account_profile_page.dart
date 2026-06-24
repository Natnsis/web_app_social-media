import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/features/home/domain/entities/post.dart';
import 'package:faithconnect/features/home/presentation/widgets/post_card.dart';
import 'package:faithconnect/features/profile/domain/entities/account_profile_content.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_state.dart';
import 'package:faithconnect/features/post/application/post_service.dart';
import 'package:faithconnect/features/post/presentation/pages/edit_post_page.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_content_filter_bar.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_content_manage_sheet.dart';
import 'package:faithconnect/features/shortvideo/application/short_video_service.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_feed_short_tile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_action_row.dart';
// import 'package:faithconnect/features/profile/presentation/widgets/personal_profile_card.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_header.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_owner_card.dart';
import 'package:faithconnect/features/profile/presentation/widgets/account_profile_shimmer.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_short_clip_card.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_scope.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_compact_card.dart';
import 'package:faithconnect/features/event/presentation/widgets/event_card.dart';
import 'package:faithconnect/features/campaign/application/campaign_service.dart';
import 'package:faithconnect/features/event/application/event_service.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/event/domain/entities/church_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountMemberInfo {
  final String displayName;
  final String? avatarUrl;
  final String? email;
  final String? phone;

  const _AccountMemberInfo({
    required this.displayName,
    this.avatarUrl,
    this.email,
    this.phone,
  });

  factory _AccountMemberInfo.fromUser(User? user) {
    final name = user?.name?.trim();
    return _AccountMemberInfo(
      displayName: (name != null && name.isNotEmpty) ? name : 'My Account',
      avatarUrl: user?.avatar,
      email: user?.email,
      phone: user?.phone,
    );
  }
}

class _AccountProfilePageState extends State<AccountProfilePage> {
  bool _didRequestProfile = false;
  bool? _lastChurchMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountProfileBloc>().add(const AccountProfileRequested());
    });
  }

  void _syncProfileRequest(bool isChurchMode) {
    if (_lastChurchMode == isChurchMode && _didRequestProfile) return;
    _lastChurchMode = isChurchMode;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AccountProfileBloc>();
      if (!_didRequestProfile || bloc.state is AccountProfileInitial) {
        _didRequestProfile = true;
        bloc.add(AccountProfileRequested(churchMode: isChurchMode));
      } else {
        bloc.add(AccountProfileContentRequested(churchMode: isChurchMode));
      }
    });
  }

  Future<void> _openEditProfile() async {
    final updated = await context.pushNamed<bool>(RoutesConstant.editProfile);
    if (updated == true && mounted) {
      context.read<AccountProfileBloc>().add(
        const AccountProfileUserRefreshRequested(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountProfileBloc, AccountProfileState>(
      builder: (context, profileState) {
        final userRoles = switch (profileState) {
          AccountProfileLoaded loaded => loaded.currentUser?.roles ?? const [],
          _ => const <String>[],
        };

        return RoleGuardBuilder(
          builder: (context, access) {
            final effective = RoleGuardAccess.resolve(
              shellRoles: access.roles,
              profileRoles: userRoles,
              shellIsChurchMode: access.isChurchMode,
            );
            _syncShellRolesIfNeeded(context, access, effective);
            _syncProfileRequest(effective.showChurchAdminUi);
            return _buildScaffold(
              context,
              isChurchMode: effective.showChurchAdminUi,
              showCreateFab: effective.showCreateActions,
              onEditProfile: _openEditProfile,
            );
          },
        );
      },
    );
  }

  void _syncShellRolesIfNeeded(
    BuildContext context,
    RoleGuardAccess shellAccess,
    RoleGuardAccess effective,
  ) {
    if (!effective.canManageChurchContent) return;
    if (shellAccess.canManageChurchContent &&
        shellAccess.roles.toSet().containsAll(effective.roles.toSet())) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HomeShellModeScope.maybeOf(context)?.applyUserRoles(effective.roles);
    });
  }

  Widget _buildScaffold(
    BuildContext context, {
    required bool isChurchMode,
    required bool showCreateFab,
    VoidCallback? onEditProfile,
  }) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocBuilder<AccountProfileBloc, AccountProfileState>(
        builder: (context, state) {
          if (state is AccountProfileLoading) {
            return const AccountProfileShimmer();
          }

          if (state is AccountProfileFailure) {
            return _AccountProfileWidthLimiter(
              child: Center(
                child: Padding(
                  padding: context.responsive.symmetricPagePadding(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.mutedText,
                        ),
                      ),
                      AppSpacing.v16,
                      PrimaryButton.feedAction(
                        text: 'Retry',
                        onPressed: () => context.read<AccountProfileBloc>().add(
                          AccountProfileRequested(churchMode: isChurchMode),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is! AccountProfileLoaded) {
            return const SizedBox.shrink();
          }

          final member = _AccountMemberInfo.fromUser(state.currentUser);

          return _AccountProfileBody(
            profile: state.profile,
            currentUser: state.currentUser,
            member: member,
            content: state.content,
            isContentLoading: state.isContentLoading,
            contentError: state.contentError,
            isChurchMode: isChurchMode,
            onEditProfile: onEditProfile,
          );
        },
      ),
    );
  }
}

enum _ProfileHubTab { saved, liked, channels, all }

enum _ProfileContentFilter { all, posts, shorts, campaigns, events }

class _AccountProfileBody extends StatefulWidget {
  final OrganizationProfile profile;
  final User? currentUser;
  final _AccountMemberInfo member;
  final AccountProfileContent? content;
  final bool isContentLoading;
  final String? contentError;
  final bool isChurchMode;
  final VoidCallback? onEditProfile;

  const _AccountProfileBody({
    required this.profile,
    required this.currentUser,
    required this.member,
    required this.content,
    required this.isContentLoading,
    this.contentError,
    required this.isChurchMode,
    this.onEditProfile,
  });

  @override
  State<_AccountProfileBody> createState() => _AccountProfileBodyState();
}

class _AccountProfileBodyState extends State<_AccountProfileBody> {
  late int _tabIndex;
  int? _filterIndex = 0;
  // bool _showPersonalProfileCard = false;

  @override
  void initState() {
    super.initState();
    _tabIndex = 0;
  }

  @override
  void didUpdateWidget(_AccountProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChurchMode != widget.isChurchMode) {
      _tabIndex = 0;
    }
  }

  OrganizationProfile get profile => widget.profile;

  _ProfileHubTab get _currentHubTab {
    if (widget.isChurchMode) {
      return switch (_tabIndex) {
        0 => _ProfileHubTab.all,
        1 => _ProfileHubTab.saved,
        2 => _ProfileHubTab.liked,
        3 => _ProfileHubTab.channels,
        _ => _ProfileHubTab.all,
      };
    } else {
      return switch (_tabIndex) {
        0 => _ProfileHubTab.saved,
        1 => _ProfileHubTab.liked,
        2 => _ProfileHubTab.channels,
        _ => _ProfileHubTab.saved,
      };
    }
  }

  List<String> get _contentFilterLabels => widget.isChurchMode
      ? ProfileContentFilterBar.churchLabels
      : ProfileContentFilterBar.memberLabels;

  bool get _showsContentFilters =>
      _currentHubTab == _ProfileHubTab.saved ||
      _currentHubTab == _ProfileHubTab.all;

  bool get _canManageContent =>
      widget.isChurchMode && _currentHubTab == _ProfileHubTab.all;

  _ProfileContentFilter get _contentFilter {
    final index = _filterIndex;
    if (index == null) return _ProfileContentFilter.all;

    final labels = _contentFilterLabels;
    if (index < 0 || index >= labels.length) {
      return _ProfileContentFilter.all;
    }

    return switch (labels[index]) {
      'Posts' => _ProfileContentFilter.posts,
      'Shorts' => _ProfileContentFilter.shorts,
      'Campaigns' => _ProfileContentFilter.campaigns,
      'Events' => _ProfileContentFilter.events,
      _ => _ProfileContentFilter.all,
    };
  }

  // Tap name / badge → show/hide PersonalProfileCard (disabled).
  // void _togglePersonalProfileCard() {
  //   setState(() => _showPersonalProfileCard = !_showPersonalProfileCard);
  // }

  Future<void> _openEditProfilePage() async {
    final updated = await context.pushNamed<bool>(RoutesConstant.editProfile);
    if (!mounted) return;
    // setState(() => _showPersonalProfileCard = false);
    if (updated == true) {
      context.read<AccountProfileBloc>().add(
        const AccountProfileUserRefreshRequested(),
      );
    }
  }

  // Future<void> _openEditProfileFromCard() => _openEditProfilePage();

  void _openAccountSettings() {
    context.pushNamed(RoutesConstant.accountSettings);
  }

  void _goToShorts() {
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      shell.goBranch(2, initialLocation: shell.currentIndex == 2);
      return;
    }
    context.go(RoutesConstant.shorts);
  }

  Future<void> _refreshContent() async {
    final bloc = context.read<AccountProfileBloc>();
    bloc.add(const AccountProfileUserRefreshRequested());
    bloc.add(AccountProfileContentRequested(churchMode: widget.isChurchMode));
    await bloc.stream.firstWhere(
      (state) => state is AccountProfileLoaded && !state.isContentLoading,
    );
  }

  void _openCreatePost() {
    context.pushNamed(RoutesConstant.newPost);
  }

  Future<void> _managePost(Post post) async {
    final action = await showProfileContentManageSheet(
      context,
      kind: ProfileContentKind.post,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ProfileContentManageAction.edit:
        final updated = await context.pushNamed<Map<String, dynamic>>(
          RoutesConstant.editPost,
          pathParameters: {'id': post.id},
          extra: post,
        );
        if (!mounted || updated == null) return;

        final content = updated['content'] as String;
        final newMedia = updated['newMedia'] as UploadedMedia?;
        final removeExistingMedia =
            updated['removeExistingMedia'] as bool? ?? false;

        final result = await sl<PostService>().updatePost(
          postId: post.id,
          content: content,
          newMedia: newMedia,
          removeExistingMedia: removeExistingMedia,
        );
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfilePostUpdated(postId: post.id, content: content),
          );
          if (newMedia != null || removeExistingMedia) {
            context.read<AccountProfileBloc>().add(
              AccountProfileContentRequested(churchMode: widget.isChurchMode),
            );
          }
          showSuccess(context, 'Post updated');
        });
      case ProfileContentManageAction.delete:
        final confirmed = await confirmProfileContentDelete(
          context,
          kind: ProfileContentKind.post,
        );
        if (!mounted || !confirmed) return;

        final result = await sl<PostService>().deletePost(post.id);
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfilePostRemoved(post.id),
          );
          showSuccess(context, 'Post deleted');
        });
    }
  }

  Future<void> _manageShort(ProfileShortClip clip) async {
    final action = await showProfileContentManageSheet(
      context,
      kind: ProfileContentKind.short,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ProfileContentManageAction.edit:
        final updated = await showProfileContentEditSheet(
          context,
          kind: ProfileContentKind.short,
          initialText: clip.title,
        );
        if (!mounted || updated == null) return;

        final result = await sl<ShortVideoService>().updateShort(
          shortId: clip.id,
          title: updated,
        );
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfileShortUpdated(shortId: clip.id, title: updated),
          );
          showSuccess(context, 'Short updated');
        });
      case ProfileContentManageAction.delete:
        final confirmed = await confirmProfileContentDelete(
          context,
          kind: ProfileContentKind.short,
        );
        if (!mounted || !confirmed) return;

        final result = await sl<ShortVideoService>().deleteShort(clip.id);
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfileShortRemoved(clip.id),
          );
          showSuccess(context, 'Short deleted');
        });
    }
  }

  Future<void> _manageCampaign(Campaign campaign) async {
    final action = await showProfileContentManageSheet(
      context,
      kind: ProfileContentKind.campaign,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ProfileContentManageAction.edit:
        final updated = await context.pushNamed<Map<String, dynamic>>(
          RoutesConstant.editCampaign,
          pathParameters: {'id': campaign.id},
          extra: campaign,
        );
        if (!mounted || updated == null) return;

        final title = updated['title'] as String;
        final goal = updated['goal'] as int?;
        final description = updated['description'] as String?;
        final newMedia = updated['newMedia'] as UploadedMedia?;
        final removeExistingMedia =
            updated['removeExistingMedia'] as bool? ?? false;

        final result = await sl<CampaignService>().updateCampaign(
          campaignId: campaign.id,
          title: title,
          goal: goal,
          description: description,
          newMedia: newMedia,
          removeExistingMedia: removeExistingMedia,
        );
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfileCampaignUpdated(
              campaignId: campaign.id,
              title: title,
            ),
          );
          if (newMedia != null || removeExistingMedia) {
            context.read<AccountProfileBloc>().add(
              AccountProfileContentRequested(churchMode: widget.isChurchMode),
            );
          }
          showSuccess(context, 'Campaign updated');
        });
      case ProfileContentManageAction.delete:
        final confirmed = await confirmProfileContentDelete(
          context,
          kind: ProfileContentKind.campaign,
        );
        if (!mounted || !confirmed) return;

        final result = await sl<CampaignService>().deleteCampaign(campaign.id);
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfileCampaignRemoved(campaign.id),
          );
          showSuccess(context, 'Campaign deleted');
        });
    }
  }

  Future<void> _manageEvent(ChurchEvent event) async {
    final action = await showProfileContentManageSheet(
      context,
      kind: ProfileContentKind.event,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case ProfileContentManageAction.edit:
        final updated = await context.pushNamed<Map<String, dynamic>>(
          RoutesConstant.editEvent,
          pathParameters: {'id': event.id},
          extra: event,
        );
        if (!mounted || updated == null) return;

        final title = updated['title'] as String;
        final date = updated['date'] as String?;
        final time = updated['time'] as String?;
        final details = updated['details'] as String?;
        final newMedia = updated['newMedia'] as UploadedMedia?;
        final removeExistingMedia =
            updated['removeExistingMedia'] as bool? ?? false;

        final result = await sl<EventService>().updateEvent(
          eventId: event.id,
          title: title,
          date: date,
          time: time,
          details: details,
          newMedia: newMedia,
          removeExistingMedia: removeExistingMedia,
        );
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfileEventUpdated(eventId: event.id, title: title),
          );
          if (newMedia != null || removeExistingMedia) {
            context.read<AccountProfileBloc>().add(
              AccountProfileContentRequested(churchMode: widget.isChurchMode),
            );
          }
          showSuccess(context, 'Event updated');
        });
      case ProfileContentManageAction.delete:
        final confirmed = await confirmProfileContentDelete(
          context,
          kind: ProfileContentKind.event,
        );
        if (!mounted || !confirmed) return;

        final result = await sl<EventService>().deleteEvent(event.id);
        if (!mounted) return;

        result.fold((failure) => showError(context, failure.message), (_) {
          context.read<AccountProfileBloc>().add(
            AccountProfileEventRemoved(event.id),
          );
          showSuccess(context, 'Event deleted');
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return OrientationBuilder(
      builder: (context, _) {
        final responsive = context.responsive;
        final sectionPadding = responsive.pagePadding(top: 8);
        final feedGap = responsive.feedItemGap;

        return RefreshIndicator(
          color: colors.brandBlue,
          backgroundColor: colors.cardBackground,
          onRefresh: _refreshContent,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _AccountProfileWidthLimiter(
                  child: ProfileHubHeader(
                    profile: profile,
                    showOrganizationProfile: widget.isChurchMode,
                    showThemeSwitch: true,
                    memberDisplayName: widget.member.displayName,
                    memberAvatarUrl: widget.member.avatarUrl,
                    memberEmail: widget.member.email,
                    memberPhone: widget.member.phone,
                    onSettings: _openAccountSettings,
                    onAvatarTap: _openEditProfilePage,
                    // onProfileTap: widget.onEditProfile != null
                    //     ? _togglePersonalProfileCard
                    //     : null,
                  ),
                ),
              ),
              // if (_showPersonalProfileCard)
              //   SliverToBoxAdapter(
              //     child: Padding(
              //       padding: sectionPadding.copyWith(top: 0),
              //       child: _AccountProfileWidthLimiter(
              //         child: PersonalProfileCard(
              //           email: widget.member.email,
              //           phone: widget.member.phone,
              //           churchName: widget.isChurchMode
              //               ? widget.currentUser?.churchName
              //               : null,
              //           churchLogoUrl: widget.isChurchMode
              //               ? widget.currentUser?.churchLogo
              //               : null,
              //           showSummary: false,
              //           onEditProfile: _openEditProfileFromCard,
              //         ),
              //       ),
              //     ),
              //   ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: sectionPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.isChurchMode) ...[
                        ProfileOwnerCard(owner: profile.owner),
                        SizedBox(height: 12.h),
                      ],
                      ProfileHubActionRow(
                        isChurchMode: widget.isChurchMode,
                        selectedIndex: _tabIndex,
                        onChanged: (index) {
                          setState(() {
                            _tabIndex = index;
                            _filterIndex = 0;
                          });
                        },
                      ),
                      if (_showsContentFilters) ...[
                        SizedBox(height: 12.h),
                        ProfileContentFilterBar(
                          labels: _contentFilterLabels,
                          selectedIndex: _filterIndex ?? -1,
                          onChanged: (index) {
                            setState(
                              () => _filterIndex = index < 0 ? null : index,
                            );
                          },
                        ),
                      ],
                      SizedBox(height: feedGap),
                    ],
                  ),
                ),
              ),
              ..._contentSlivers(responsive),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _contentSlivers(ResponsiveHelper responsive) {
    switch (_currentHubTab) {
      case _ProfileHubTab.liked:
      case _ProfileHubTab.channels:
      case _ProfileHubTab.saved:
      case _ProfileHubTab.all:
        return _savedSlivers(responsive);
    }
  }

  List<Widget> _savedSlivers(ResponsiveHelper responsive) {
    if (widget.contentError != null) {
      return [
        SliverToBoxAdapter(
          child: _AccountProfileWidthLimiter(
            child: FaithEmptyState(
              icon: Iconsax.warning_2,
              title: 'Couldn\'t load content',
              subtitle: widget.contentError,
              actionLabel: 'Try again',
              onAction: _refreshContent,
            ),
          ),
        ),
        _navBarBottomSliver(responsive),
      ];
    }

    if (widget.isContentLoading || widget.content == null) {
      return AccountProfileShimmer.feedSlivers(context);
    }

    final content = widget.content!;

    switch (_contentFilter) {
      case _ProfileContentFilter.shorts:
        return _shortsGridSlivers(content.shorts, responsive: responsive);
      case _ProfileContentFilter.campaigns:
        if (content.campaigns.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: _AccountProfileWidthLimiter(
                child: FaithEmptyState(
                  icon: Iconsax.flag,
                  title: 'No campaigns yet',
                  subtitle: 'Launch a campaign to engage your community.',
                  actionLabel: widget.isChurchMode ? 'Create campaign' : null,
                  onAction: widget.isChurchMode
                      ? () => context.pushNamed(RoutesConstant.campaigns)
                      : null,
                ),
              ),
            ),
            _navBarBottomSliver(responsive),
          ];
        }
        return [
          ..._campaignListSlivers(content.campaigns, responsive),
          _navBarBottomSliver(responsive),
        ];
      case _ProfileContentFilter.events:
        if (content.events.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: _AccountProfileWidthLimiter(
                child: FaithEmptyState(
                  icon: Iconsax.calendar,
                  title: 'No events yet',
                  subtitle: 'Schedule gatherings and share them with members.',
                ),
              ),
            ),
            _navBarBottomSliver(responsive),
          ];
        }
        return [
          ..._eventListSlivers(content.events, responsive),
          _navBarBottomSliver(responsive),
        ];
      case _ProfileContentFilter.posts:
        final posts = [...content.posts, ...content.videos];
        if (posts.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: _AccountProfileWidthLimiter(
                child: FaithEmptyState(
                  icon: Iconsax.document_text,
                  title: 'No posts yet',
                  subtitle:
                      'Share updates, photos, and videos with your community.',
                  actionLabel: widget.isChurchMode ? 'Create post' : null,
                  onAction: widget.isChurchMode ? _openCreatePost : null,
                ),
              ),
            ),
            _navBarBottomSliver(responsive),
          ];
        }
        return [
          ..._postListSlivers(posts, responsive),
          _navBarBottomSliver(responsive),
        ];
      case _ProfileContentFilter.all:
        return _allSavedSlivers(content, responsive);
    }
  }

  List<Widget> _allSavedSlivers(
    AccountProfileContent content,
    ResponsiveHelper responsive,
  ) {
    if (content.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _AccountProfileWidthLimiter(
            child: FaithEmptyState(
              icon: Iconsax.gallery,
              title: widget.isChurchMode
                  ? 'No content published yet'
                  : 'Nothing saved yet',
              subtitle: widget.isChurchMode
                  ? 'Posts, shorts, campaigns, and events will appear here.'
                  : 'Save posts and shorts to find them quickly later.',
              actionLabel: widget.isChurchMode ? 'Create post' : null,
              onAction: widget.isChurchMode ? _openCreatePost : null,
            ),
          ),
        ),
        _navBarBottomSliver(responsive),
      ];
    }

    final featuredShort = content.shorts.isNotEmpty
        ? content.shorts.first
        : null;
    final gridShorts = content.shorts.length > 1
        ? content.shorts.sublist(1)
        : const <ProfileShortClip>[];

    return [
      ..._postListSlivers(content.posts.take(1).toList(), responsive),
      if (content.campaigns.isNotEmpty)
        ..._campaignListSlivers(content.campaigns.take(2).toList(), responsive),
      if (featuredShort != null)
        SliverToBoxAdapter(
          child: _AccountProfileWidthLimiter(
            child: Padding(
              padding: EdgeInsets.only(bottom: responsive.feedItemGap),
              child: ProfileFeedShortTile(
                clip: featuredShort,
                onTap: _goToShorts,
                showManageActions: _canManageContent,
                onManageTap: () => _manageShort(featuredShort),
              ),
            ),
          ),
        ),
      if (content.events.isNotEmpty)
        ..._eventListSlivers(content.events.take(2).toList(), responsive),
      ..._postListSlivers(content.videos.take(1).toList(), responsive),
      if (gridShorts.isNotEmpty)
        ..._shortsGridSlivers(
          gridShorts,
          responsive: responsive,
          includeNavBarPad: false,
        ),
      if (content.posts.length > 1)
        ..._postListSlivers(content.posts.sublist(1), responsive),
      if (content.campaigns.length > 2)
        ..._campaignListSlivers(content.campaigns.sublist(2), responsive),
      if (content.events.length > 2)
        ..._eventListSlivers(content.events.sublist(2), responsive),
      if (content.videos.length > 1)
        ..._postListSlivers(content.videos.sublist(1), responsive),
      _navBarBottomSliver(responsive),
    ];
  }

  SliverToBoxAdapter _navBarBottomSliver(ResponsiveHelper responsive) {
    return SliverToBoxAdapter(
      child: SizedBox(height: responsive.bottomNavClearance),
    );
  }

  List<Widget> _postListSlivers(List<Post> posts, ResponsiveHelper responsive) {
    if (posts.isEmpty) return const [];
    return [
      SliverPadding(
        padding: responsive.pagePadding(),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = posts[index];
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.feedItemGap),
              child: PostCard(
                post: post,
                showManageActions: _canManageContent,
                onManageTap: () => _managePost(post),
              ),
            );
          }, childCount: posts.length),
        ),
      ),
    ];
  }

  List<Widget> _campaignListSlivers(
    List<Campaign> campaigns,
    ResponsiveHelper responsive,
  ) {
    if (campaigns.isEmpty) return const [];
    return [
      SliverPadding(
        padding: responsive.pagePadding(),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final campaign = campaigns[index];
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.feedItemGap),
              child: Stack(
                children: [
                  CampaignCompactCard(
                    campaign: campaign,
                    onTap: () => context.pushNamed(
                      RoutesConstant.campaignDetail,
                      pathParameters: {'id': campaign.id},
                    ),
                  ),
                  if (_canManageContent)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white70,
                        ),
                        onPressed: () => _manageCampaign(campaign),
                      ),
                    ),
                ],
              ),
            );
          }, childCount: campaigns.length),
        ),
      ),
    ];
  }

  List<Widget> _eventListSlivers(
    List<ChurchEvent> events,
    ResponsiveHelper responsive,
  ) {
    if (events.isEmpty) return const [];
    return [
      SliverPadding(
        padding: responsive.pagePadding(),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final event = events[index];
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.feedItemGap),
              child: Stack(
                children: [
                  EventCard(event: event),
                  if (_canManageContent)
                    Positioned(
                      top: 10.h,
                      right: 28.w, // inside the EventCard margin
                      child: IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: context.faithColors.mutedText,
                        ),
                        onPressed: () => _manageEvent(event),
                      ),
                    ),
                ],
              ),
            );
          }, childCount: events.length),
        ),
      ),
    ];
  }

  List<Widget> _shortsGridSlivers(
    List<ProfileShortClip> shorts, {
    required ResponsiveHelper responsive,
    bool includeNavBarPad = true,
  }) {
    if (shorts.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _AccountProfileWidthLimiter(
            child: FaithEmptyState(
              icon: Iconsax.video_play,
              title: 'No shorts yet',
              subtitle: 'Short videos from your community will show up here.',
              actionLabel: widget.isChurchMode ? 'Browse shorts' : null,
              onAction: widget.isChurchMode ? _goToShorts : null,
            ),
          ),
        ),
        if (includeNavBarPad) _navBarBottomSliver(responsive),
      ];
    }

    final columns = responsive.shortsGridColumns;
    final spacing = responsive.isCompactWidth ? 8.w : 10.w;

    return [
      SliverPadding(
        padding: responsive.pagePadding(),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: responsive.isLandscape ? 10 / 14 : 9 / 14,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final clip = shorts[index];
            return ProfileShortClipCard(
              clip: clip,
              onTap: _goToShorts,
              showManageActions: _canManageContent,
              onManageTap: () => _manageShort(clip),
            );
          }, childCount: shorts.length),
        ),
      ),
      if (includeNavBarPad) _navBarBottomSliver(responsive),
    ];
  }
}

/// Centers profile content and caps width on tablets and desktops.
class _AccountProfileWidthLimiter extends StatelessWidget {
  final Widget child;

  const _AccountProfileWidthLimiter({required this.child});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
        child: child,
      ),
    );
  }
}
