import 'dart:async';

import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaigns_hub_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaigns_hub_event.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaigns_hub_state.dart';
import 'package:faithconnect/features/campaign/presentation/navigation/campaign_navigation.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_app_bar.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_compact_card.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_completed_tile.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_featured_card.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_filter_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignsHubPage extends StatefulWidget {
  final bool openCreateOnLoad;

  const CampaignsHubPage({
    super.key,
    this.openCreateOnLoad = false,
  });

  @override
  State<CampaignsHubPage> createState() => _CampaignsHubPageState();
}

class _CampaignsHubPageState extends State<CampaignsHubPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  bool _didAutoOpenCreate = false;
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<CampaignsHubBloc>().add(const CampaignsHubRequested());
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoOpenCreate());
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<CampaignsHubBloc>().add(
            CampaignsHubSearchChanged(_searchController.text),
          );
    });
  }

  void _toggleSearch() {
    setState(() {
      _searchExpanded = !_searchExpanded;
      if (!_searchExpanded) {
        _searchController.clear();
        context.read<CampaignsHubBloc>().add(const CampaignsHubSearchChanged(''));
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

  void _openDetail(String id) {
    CampaignNavigation.openDetail(context, id);
  }

  Future<void> _maybeAutoOpenCreate() async {
    if (_didAutoOpenCreate || !mounted) return;
    final state = context.read<CampaignsHubBloc>().state;
    if (state is CampaignsHubLoaded) {
      _didAutoOpenCreate = true;
      await _openCreateFlow();
    }
  }

  Future<void> _openCreateFlow() async {
    if (!context.readRoleAccess().showCreateActions) {
      showInfo(
        context,
        'Creating campaigns is only available for church administrator accounts.',
      );
      return;
    }

    final campaignId = await CampaignNavigation.openCreate(context);
    if (!mounted) return;

    context.read<CampaignsHubBloc>().add(const CampaignsHubRefreshed());

    if (campaignId != null && campaignId.isNotEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      _openDetail(campaignId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final titleColor = isDark ? Colors.white : colors.primaryText;
    final mutedColor = isDark ? DarkTheme.feedMutedText : colors.mutedText;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: CampaignAppBar(
        title: 'Campaigns',
        iconColor: colors.iconMuted,
        showSearch: true,
        onSearchTap: _toggleSearch,
      ),
      body: Column(
        children: [
          if (_searchExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
              child: CustomMessageTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hint: 'Search campaigns...',
                showEmojiButton: false,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => context.read<CampaignsHubBloc>().add(
                      CampaignsHubSearchChanged(value),
                    ),
              ),
            ),
          Expanded(
            child: BlocConsumer<CampaignsHubBloc, CampaignsHubState>(
        listener: (context, state) {
          if (widget.openCreateOnLoad && !_didAutoOpenCreate) {
            if (state is CampaignsHubLoaded) {
              _maybeAutoOpenCreate();
            }
          }
        },
        builder: (context, state) {
          if (state is CampaignsHubLoading) {
            return const Center(
              child: CircularProgressIndicator(color: DarkTheme.brandBlue),
            );
          }

          if (state is CampaignsHubFailure) {
            return Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    AppSpacing.v16,
                    PrimaryButton.feedAction(
                      text: 'Retry',
                      onPressed: () => context
                          .read<CampaignsHubBloc>()
                          .add(const CampaignsHubRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! CampaignsHubLoaded) {
            return const SizedBox.shrink();
          }

          final content = state.content;
          final featured = content.featuredCampaign;
          final listCampaigns = content.campaigns
              .where((c) => featured == null || c.id != featured.id)
              .toList();

          return RefreshIndicator(
            color: DarkTheme.brandBlue,
            backgroundColor: colors.cardBackground,
            onRefresh: () async {
              context
                  .read<CampaignsHubBloc>()
                  .add(const CampaignsHubRefreshed());
              await context.read<CampaignsHubBloc>().stream.firstWhere(
                    (s) => s is CampaignsHubLoaded || s is CampaignsHubFailure,
                  );
            },
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              children: [
                Text(
                  'Campaigns Hub',
                  style: GoogleFonts.inter(
                    color: titleColor,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Transparent stewardship for the missions that matter most to our global community.',
                  style: GoogleFonts.inter(
                    color: mutedColor,
                    fontSize: 14.sp,
                    height: 1.45,
                  ),
                ),
                RoleGuard(
                  requirement: AppRoleRequirement.elevated,
                  behavior: RoleGuardBehavior.hide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.h),
                      PrimaryButton.feedAction(
                        text: 'Create Campaign',
                        onPressed: _openCreateFlow,
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                CampaignFilterTabs(
                  selected: content.filter,
                  onChanged: (filter) => context
                      .read<CampaignsHubBloc>()
                      .add(CampaignsHubFilterChanged(filter)),
                ),
                SizedBox(height: 20.h),
                if (featured != null) ...[
                  CampaignFeaturedCard(
                    campaign: featured,
                    onTap: () => _openDetail(featured.id),
                  ),
                  SizedBox(height: 12.h),
                ],
                if (listCampaigns.isEmpty &&
                    content.searchQuery.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      'No campaigns found for "${content.searchQuery}".',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: mutedColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ] else
                  ...listCampaigns.map(
                    (campaign) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: CampaignCompactCard(
                        campaign: campaign,
                        onTap: () => _openDetail(campaign.id),
                      ),
                    ),
                  ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      'Completed Missions',
                      style: GoogleFonts.inter(
                        color: titleColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          showInfo(context, 'Archive coming soon'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Archive',
                            style: GoogleFonts.inter(
                              color: mutedColor,
                              fontSize: 13.sp,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 16.r,
                            color: mutedColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ...content.completedCampaigns.map(
                  (campaign) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: CampaignCompletedTile(
                      campaign: campaign,
                      onTap: () => _openDetail(campaign.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
            ),
          ),
        ],
      ),
    );
  }
}
