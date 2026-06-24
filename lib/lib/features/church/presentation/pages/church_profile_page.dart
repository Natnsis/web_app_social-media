import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_group.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_ids.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_tab.dart';
import 'package:faithconnect/features/church/presentation/mappers/church_profile_group_mapper.dart';
import 'package:faithconnect/features/chat/presentation/navigation/group_governance_navigation.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_bloc.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_event.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_state.dart';
import 'package:faithconnect/features/church/presentation/widgets/church_profile_empty_tab.dart';
import 'package:faithconnect/features/church/presentation/widgets/church_profile_header.dart';
import 'package:faithconnect/features/church/presentation/widgets/unfollow_church_dialog.dart';
import 'package:faithconnect/features/church/presentation/widgets/church_profile_campaigns_content.dart';
import 'package:faithconnect/features/church/presentation/widgets/church_profile_groups_content.dart';
import 'package:faithconnect/features/church/presentation/widgets/church_profile_members_content.dart';
import 'package:faithconnect/features/church/presentation/widgets/church_profile_posts_content.dart';
import 'package:faithconnect/features/church/presentation/widgets/church_profile_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';
import 'package:faithconnect/core/widgets/in_app_webview_page.dart';
import 'package:faithconnect/features/home/gift/data/dto/send_gift_dto.dart';
import 'package:faithconnect/features/home/gift/application/gift_service.dart';
import 'package:faithconnect/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:faithconnect/features/church/domain/access/church_edit_access.dart';
import 'package:faithconnect/features/church/presentation/navigation/church_navigation.dart';

class ChurchProfilePage extends StatefulWidget {
  final String profileId;
  final GiftItem? pendingGift;

  const ChurchProfilePage({
    super.key,
    required this.profileId,
    this.pendingGift,
  });

  @override
  State<ChurchProfilePage> createState() => _ChurchProfilePageState();
}

class _ChurchProfilePageState extends State<ChurchProfilePage> {
  bool _isSendingGift = false;

  Future<void> _sendGift() async {
    if (widget.pendingGift == null || _isSendingGift) return;

    setState(() => _isSendingGift = true);

    final dto = SendGiftDto(
      giftCatalogId: widget.pendingGift!.id,
      recipientChurchId: widget.profileId,
      quantity: 1,
      message: 'A gift from your profile!',
    );

    final result = await sl<GiftService>().sendGift(dto);

    if (!mounted) return;
    setState(() => _isSendingGift = false);

    await result.fold(
      (failure) async {
        showError(context, failure.message);
      },
      (checkoutInfo) async {
        final success = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => InAppWebViewPage(
              url: checkoutInfo.checkoutUrl,
              title: 'Complete Gift Payment',
              returnUrl: 'google.com',
            ),
          ),
        );

        if (!mounted) return;
        
        setState(() => _isSendingGift = true);
        final statusResult = await sl<GiftService>().checkTransactionStatus(checkoutInfo.txRef);
        
        if (!mounted) return;
        setState(() => _isSendingGift = false);

        statusResult.fold(
          (failure) => showWarning(context, failure.message),
          (status) {
            showSuccess(context, status);
            context.pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: BlocConsumer<ChurchBloc, ChurchState>(
        listenWhen: (previous, current) =>
            current is ChurchProfileLoaded && current.followActionError != null,
        listener: (context, state) {
          if (state is! ChurchProfileLoaded ||
              state.followActionError == null) {
            return;
          }
          showWarning(context, state.followActionError!);
          context.read<ChurchBloc>().add(const ChurchFollowActionCleared());
        },
        builder: (context, state) => _buildBody(context, state),
        ),
      ),
      bottomNavigationBar: widget.pendingGift != null
          ? _PendingGiftBottomBar(
              gift: widget.pendingGift!,
              isSending: _isSendingGift,
              onSend: _sendGift,
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, ChurchState state) {
    switch (state) {
      case ChurchFailure failure:
        if (failure.profileId != widget.profileId) {
          return const ChurchProfileShimmer();
        }
        return _ChurchProfileError(
          message: failure.message,
          onRetry: () => context.read<ChurchBloc>().add(
            ChurchProfileRequested(widget.profileId),
          ),
        );
      case ChurchProfileLoaded loaded:
        if (loaded.requestedProfileId != widget.profileId) {
          return const ChurchProfileShimmer();
        }
        return _ChurchProfileContent(
          profileId: widget.profileId,
          state: loaded,
        );
      case ChurchLoading _:
      case ChurchInitial _:
        return const ChurchProfileShimmer();
    }
  }
}

class _ChurchProfileError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChurchProfileError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: colors.iconPrimary,
                size: 22.r,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.primaryText),
                    ),
                    AppSpacing.v16,
                    PrimaryButton.feedAction(
                      text: 'Retry',
                      onPressed: onRetry,
                      width: 160.w,
                      icon: const Icon(
                        Iconsax.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChurchProfileContent extends StatefulWidget {
  final String profileId;
  final ChurchProfileLoaded state;

  const _ChurchProfileContent({required this.profileId, required this.state});

  @override
  State<_ChurchProfileContent> createState() => _ChurchProfileContentState();
}

class _ChurchProfileContentState extends State<_ChurchProfileContent> {
  String? _associatedChurchId;

  @override
  void initState() {
    super.initState();
    _loadAssociatedChurchId();
  }

  Future<void> _loadAssociatedChurchId() async {
    final user = await SharedPrefsService.getUser();
    if (!mounted) return;
    setState(() => _associatedChurchId = user?.churchId?.trim());
  }

  ChurchProfileLoaded get state => widget.state;
  String get profileId => widget.profileId;

  @override
  Widget build(BuildContext context) {
    final feed = state.profileFeed;
    final colors = context.faithColors;

    return RoleGuardBuilder(
      builder: (context, access) {
        final canEdit = ChurchEditAccess.canEdit(
          access: access,
          viewedProfileId: profileId,
          profile: feed.profile,
          associatedChurchId: _associatedChurchId,
        );
        final isOwnChurch = canEdit ||
            ChurchProfileIds.isMyChurch(profileId) ||
            (_associatedChurchId != null &&
                feed.profile.id == _associatedChurchId);
        final bannerUnderlay = const Color(0xFF12151C);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: ColoredBox(color: colors.scaffoldBackground),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 280.h + MediaQuery.viewPaddingOf(context).top,
              child: ColoredBox(color: bannerUnderlay),
            ),
            RefreshIndicator(
              color: colors.brandBlue,
              backgroundColor: colors.cardBackground,
              onRefresh: () async {
                context.read<ChurchBloc>().add(ChurchProfileRefreshed(profileId));
                await context.read<ChurchBloc>().stream.firstWhere(
                  (s) =>
                      s is ChurchProfileLoaded &&
                      s.requestedProfileId == profileId &&
                      !s.isRefreshing,
                );
              },
              child: CustomScrollView(
                clipBehavior: Clip.hardEdge,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: ChurchProfileHeader(
                      profile: feed.profile,
                      appBarTitle: _truncate(feed.profile.name, 14),
                      selectedTab: state.selectedTab,
                      showFollowAction: !isOwnChurch,
                      onEditTap: canEdit
                          ? () => _handleEditProfile(context, feed.profile)
                          : null,
                      onTabChanged: (tab) => context.read<ChurchBloc>().add(
                        ChurchProfileTabChanged(tab),
                      ),
                      onFollowTap: () =>
                          _handleFollowAction(context, feed.profile),
                      onBack: () => Navigator.of(context).maybePop(),
                      onLocationTap: () => showInfo(
                        context,
                        feed.profile.locationLabel ?? 'Location coming soon',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                  ..._tabSlivers(context, state, isOwnChurch: isOwnChurch),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                ],
              ),
            ),
            if (state.isRefreshing)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: colors.brandBlue,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _tabSlivers(
    BuildContext context,
    ChurchProfileLoaded state, {
    required bool isOwnChurch,
  }) {
    switch (state.selectedTab) {
      case ChurchProfileTab.members:
        if (state.profileFeed.members.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: ChurchProfileEmptyTab(message: 'No members yet'),
            ),
          ];
        }
        return ChurchProfileMembersContent.buildSlivers(
          state.profileFeed.members,
        );
      case ChurchProfileTab.posts:
        if (state.profileFeed.posts.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: ChurchProfileEmptyTab(message: 'No posts yet'),
            ),
          ];
        }
        return ChurchProfilePostsContent.buildSlivers(state.profileFeed);
      case ChurchProfileTab.campaigns:
        if (state.profileFeed.campaigns.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: ChurchProfileEmptyTab(message: 'No campaigns yet'),
            ),
          ];
        }
        return ChurchProfileCampaignsContent.buildSlivers(
          state.profileFeed.campaigns,
        );
      case ChurchProfileTab.groups:
        if (state.profileFeed.groups.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: ChurchProfileEmptyTab(message: 'No groups yet'),
            ),
          ];
        }
        return ChurchProfileGroupsContent.buildSlivers(
          groups: state.profileFeed.groups,
          isMyChurch: isOwnChurch,
          onGroupTap: (group) => _openGroup(context, group, isOwnChurch: isOwnChurch),
        );
    }
  }

  void _openGroup(
    BuildContext context,
    ChurchProfileGroup group, {
    required bool isOwnChurch,
  }) {
    GroupGovernanceNavigation.showGroupInfoSheet(
      context,
      room: ChurchProfileGroupMapper.toChatRoom(group),
      showJoinRequestAction: !isOwnChurch,
      showAdminActions: isOwnChurch,
    );
  }

  String _truncate(String value, int maxChars) {
    if (value.length <= maxChars) return value;
    return '${value.substring(0, maxChars)}...';
  }

  Future<void> _handleFollowAction(
    BuildContext context,
    ChurchProfile profile,
  ) async {
    if (profile.isFollowing) {
      final confirmed = await showUnfollowChurchDialog(
        context,
        churchName: profile.name,
      );
      if (!confirmed || !context.mounted) return;
      context.read<ChurchBloc>().add(const ChurchProfileUnfollowRequested());
      return;
    }

    context.read<ChurchBloc>().add(const ChurchProfileFollowToggled());
  }

  Future<void> _handleEditProfile(
    BuildContext context,
    ChurchProfile profile,
  ) async {
    final result = await ChurchNavigation.openEditChurchProfile(
      context,
      viewedProfileId: profileId,
      profile: profile,
      associatedChurchId: _associatedChurchId,
    );
    if (result == true && context.mounted) {
      context.read<ChurchBloc>().add(ChurchProfileRequested(profileId));
    }
  }
}

class _PendingGiftBottomBar extends StatelessWidget {
  final GiftItem gift;
  final bool isSending;
  final VoidCallback onSend;

  const _PendingGiftBottomBar({
    required this.gift,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        16.h + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: colors.tagBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.gift, color: colors.brandBlue, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send ${gift.name}',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Cost: ${gift.priceEtb.toInt()} Coins',
                  style: GoogleFonts.inter(
                    color: colors.brandBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton.feedAction(
            text: isSending ? 'Sending...' : 'Confirm',
            onPressed: isSending ? null : onSend,
          ),
        ],
      ),
    );
  }
}
