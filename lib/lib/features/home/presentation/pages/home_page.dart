import 'dart:async';
import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_bloc.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_event.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_state.dart';
import 'package:faithconnect/features/scripture/presentation/widgets/daily_verse_section.dart';
import 'package:faithconnect/features/home/presentation/widgets/home_app_bar.dart';
import 'package:faithconnect/features/home/presentation/widgets/home_fab_speed_dial.dart';
import 'package:faithconnect/features/home/presentation/widgets/home_sidebar_drawer.dart';
import 'package:faithconnect/features/home/presentation/widgets/home_feed_shimmer.dart';
import 'package:faithconnect/features/home/presentation/widgets/live_now_section.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_event.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_nearby_section.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_bloc.dart';
import 'package:faithconnect/features/event/presentation/bloc/events_feed_event.dart';
import 'package:faithconnect/features/event/presentation/widgets/events_feed_section.dart';
import 'package:faithconnect/features/campaign/presentation/navigation/campaign_navigation.dart';
import 'package:faithconnect/features/notifications/presentation/navigation/notifications_navigation.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/station_repository.dart';
import 'package:faithconnect/features/live_streaming/presentation/navigation/live_stream_navigation.dart';
import 'package:faithconnect/features/auth/presentation/widgets/pending_otp_verification_host.dart';
import 'package:faithconnect/features/home/presentation/widgets/post_card.dart';
import 'package:faithconnect/core/services/socket/user_location_socket_service.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_search_bloc.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_search_event.dart';
import 'package:faithconnect/features/home/presentation/blocs/home_search_state.dart';
import 'package:faithconnect/features/event/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:faithconnect/injection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final HomeSearchBloc _searchBloc;
  Timer? _backgroundRefreshTimer;
  bool _fabMenuOpen = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<HomeSearchBloc>();
    _loadFeed();

    _backgroundRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        context.read<HomeBloc>().add(const HomeFeedBackgroundRefreshed());
      }
    });

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NearbyBloc>().add(
        const NearbyRefreshed(useHomePreview: true),
      );
      context.read<EventsFeedBloc>().add(const EventsFeedRequested());
      
      // Automatically start background GPS tracking
      sl<UserLocationSocketService>().startStreaming();
    });
  }

  @override
  void dispose() {
    _backgroundRefreshTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<HomeBloc>().state;
    if (state is HomeLoaded && state.hasUpdatesAvailable == true) {
      if (_scrollController.hasClients && _scrollController.offset <= 0) {
        // Auto-apply if at the absolute top
        context.read<HomeBloc>().add(const HomeFeedApplyUpdates());
      }
    }
  }

  @override
  void activate() {
    super.activate();
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      final state = context.read<HomeBloc>().state;
      if (state is! HomeLoaded && state is! HomeLoading) {
        _loadFeed();
      }
      context.read<NearbyBloc>().add(
        const NearbyRefreshed(useHomePreview: true),
      );
    }
  }

  void _loadFeed() {
    context.read<HomeBloc>().add(const HomeFeedRequested());
  }

  void _closeFabMenu() => setState(() => _fabMenuOpen = false);

  void _toggleFabMenu() => setState(() => _fabMenuOpen = !_fabMenuOpen);

  Future<void> _handleStartLive() async {
    final repo = sl<StationRepository>();
    final result = await repo.getStations();

    await result.fold((failure) async {
      if (!mounted) return;
      showError(context, failure.message);
    }, (stations) async {
      if (!mounted) return;
      if (stations.isEmpty) {
        final create = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('No Station Found'),
            content: const Text(
              'You need a station before you can start a livestream. Create one now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Create'),
              ),
            ],
          ),
        );

        if (create != true) return;

        final createRes = await repo.createStation(
          name: 'Apostolic Church',
          description: 'Test mode',
          type: 'tv',
        );

        await createRes.fold((failure) async {
          if (!mounted) return;
          showError(context, failure.message);
        }, (station) {
          if (!mounted) return;
          LiveStreamNavigation.openGoLive(context);
        });
      } else {
        LiveStreamNavigation.openGoLive(context);
      }
    });
  }

  List<HomeFabSpeedDialAction> _speedDialActions() {
    return [
      HomeFabSpeedDialAction(
        label: 'Create Group',
        icon: Iconsax.people,
        onTap: () {
          _closeFabMenu();
          context.pushNamed(RoutesConstant.newGroup);
        },
      ),
      HomeFabSpeedDialAction(
        label: 'Create Campaign',
        icon: Iconsax.speaker,
        onTap: () {
          _closeFabMenu();
          CampaignNavigation.openHub(context);
        },
      ),
      HomeFabSpeedDialAction(
        label: 'Start Live',
        icon: Iconsax.video_play,
        onTap: () {
          _closeFabMenu();
          _handleStartLive();
        },
      ),
      HomeFabSpeedDialAction(
        label: 'Create Post',
        icon: Iconsax.edit,
        onTap: () {
          _closeFabMenu();
          context.push(RoutesConstant.newPost);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Builder(
        builder: (context) {
          return PendingOtpVerificationHost(
            child: RoleGuardBuilder(
              builder: (context, access) {
                final showCreateFab = access.showCreateActions;
                if (!showCreateFab && _fabMenuOpen) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _closeFabMenu();
                  });
                }

                final colors = context.faithColors;

                return AppBarPageScaffold(
                  scaffoldKey: _scaffoldKey,
                  backgroundColor: colors.scaffoldBackground,
                  drawer: const HomeSidebarDrawer(),
                  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                  floatingActionButton: showCreateFab && !_isSearching
                      ? FaithFab.mini(
                          heroTag: 'fab_home',
                          onPressed: _toggleFabMenu,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _fabMenuOpen ? Icons.close_rounded : Icons.add_rounded,
                              key: ValueKey(_fabMenuOpen),
                            ),
                          ),
                        )
                      : null,
                  appBar: _isSearching
                      ? _buildSearchAppBar(context)
                      : HomeAppBar(
                          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                          onSearchTap: () {
                            setState(() {
                              _isSearching = true;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _searchFocusNode.requestFocus();
                            });
                          },
                          onNotificationsTap: () => NotificationsNavigation.open(context),
                        ),
                  body: MultiBlocListener(
                    listeners: [
                      BlocListener<HomeBloc, HomeState>(
                        listener: (context, state) {
                          if (state is HomeFailure) {
                            Future.delayed(const Duration(seconds: 4), () {
                              if (mounted) _loadFeed();
                            });
                          }
                        },
                      ),
                    ],
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) => _buildFeedBody(context, state),
                        ),
                        BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            if (state is HomeLoaded && state.hasUpdatesAvailable == true) {
                              return Positioned(
                                top: 16.h,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Material(
                                    color: colors.brandBlue,
                                    borderRadius: BorderRadius.circular(24.r),
                                    elevation: 4,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24.r),
                                      onTap: () {
                                        context.read<HomeBloc>().add(const HomeFeedApplyUpdates());
                                        if (_scrollController.hasClients) {
                                          _scrollController.animateTo(
                                            0,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut,
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.arrow_upward, color: Colors.white, size: 16.r),
                                            SizedBox(width: 6.w),
                                            Text(
                                              'New posts',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        if (_isSearching)
                          Positioned.fill(
                            child: Container(
                              color: colors.scaffoldBackground,
                              child: _buildSearchResultsBody(context),
                            ),
                          ),
                        if (showCreateFab && !_isSearching)
                          HomeFabSpeedDial(
                            isOpen: _fabMenuOpen,
                            onClose: _closeFabMenu,
                            actions: _speedDialActions(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(const HomeFeedRefreshed());
    context.read<NearbyBloc>().add(const NearbyRefreshed(useHomePreview: true));
    context.read<EventsFeedBloc>().add(const EventsFeedRefreshed());
    await context.read<HomeBloc>().stream.firstWhere(
      (s) => s is HomeLoaded || s is HomeFailure,
    );
  }

  Widget _buildFeedBody(BuildContext context, HomeState state) {
    final isLoading = state is HomeLoading || state is HomeInitial || state is HomeFailure;
    final feed = state is HomeLoaded ? state.feed : null;

    return RefreshIndicator(
      color: DarkTheme.brandBlue,
      backgroundColor: DarkTheme.feedCardBackground,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (isLoading)
            const SliverToBoxAdapter(child: HomeFeedShimmer())
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: LiveNowSection(items: feed!.liveNow),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: DailyVerseSection(verses: feed.allDailyVerses),
              ),
            ),
          ],
          const SliverToBoxAdapter(
            child: DiscoveryNearbySection(
              topSpacing: 20,
              bottomSpacing: 20,
              alwaysShowSection: true,
            ),
          ),
          const SliverToBoxAdapter(
            child: EventsFeedSection(topSpacing: 20, bottomSpacing: 20),
          ),
          if (isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _postShimmerPlaceholder(context),
              ),
            )
          else if (feed != null) ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => PostCard(post: feed.posts[index]),
                childCount: feed.posts.length,
              ),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 88.h)),
        ],
      ),
    );
  }

  Widget _postShimmerPlaceholder(BuildContext context) {
    final fill = faithShimmerFill(context);
    return FaithShimmer(
      child: Column(
        children: [
          _shimmerBox(height: 320.h, fill: fill),
          SizedBox(height: 16.h),
          _shimmerBox(height: 280.h, fill: fill),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, required Color fill}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.base.r),
      ),
    );
  }

  void _exitSearch() {
    _searchController.clear();
    _searchBloc.add(const SearchCleared());
    setState(() {
      _isSearching = false;
    });
  }

  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    final colors = context.faithColors;
    return AppBar(
      backgroundColor: colors.scaffoldBackground,
      foregroundColor: colors.iconPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon:  Icon(Icons.arrow_back_ios),
        onPressed: _exitSearch,
        tooltip: 'Back',
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(
          color: colors.primaryText,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Search posts and events...',
          hintStyle: TextStyle(
            color: colors.mutedText,
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
        ),
        onChanged: (query) {
          context.read<HomeSearchBloc>().add(SearchQueryChanged(query));
        },
      ),
      actions: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, _) {
            if (value.text.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  context.read<HomeSearchBloc>().add(const SearchQueryChanged(''));
                },
                tooltip: 'Clear',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSearchResultsBody(BuildContext context) {
    final colors = context.faithColors;

    return BlocBuilder<HomeSearchBloc, HomeSearchState>(
      builder: (context, state) {
        if (state is HomeSearchInitial) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.search_normal_copy,
                  size: 64.r,
                  color: colors.mutedText.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Search posts and events',
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Type keywords to find content',
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HomeSearchLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ListView(
              children: [
                SizedBox(height: 16.h),
                _searchShimmerPlaceholder(context),
              ],
            ),
          );
        }

        if (state is HomeSearchFailure) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: colors.error),
            ),
          );
        }

        if (state is HomeSearchLoaded) {
          final query = state.query;
          final activeTab = state.activeTab;
          final posts = state.posts;
          final events = state.events;

          if (posts.isEmpty && events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.search_status_copy,
                    size: 64.r,
                    color: colors.mutedText.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No results found',
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We couldn\'t find anything for "$query"',
                    style: TextStyle(
                      color: colors.mutedText,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSearchTabs(context, activeTab),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 32.h),
                  children: [
                    if (activeTab == 0) ...[
                      if (events.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                          child: Text(
                            'Events',
                            style: GoogleFonts.inter(
                              color: colors.primaryText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...events.take(3).map((e) => EventCard(event: e)),
                        if (events.length > 3)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  context.read<HomeSearchBloc>().add(const SearchTabChanged(2));
                                },
                                child: Text(
                                  'See more events',
                                  style: TextStyle(color: colors.brandBlue),
                                ),
                              ),
                            ),
                          ),
                      ],
                      if (posts.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                          child: Text(
                            'Posts',
                            style: GoogleFonts.inter(
                              color: colors.primaryText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...posts.map((p) => PostCard(post: p)),
                      ],
                    ] else if (activeTab == 1) ...[
                      if (posts.isEmpty)
                        _buildEmptyTabResults(context, 'posts')
                      else
                        ...posts.map((p) => PostCard(post: p)),
                    ] else ...[
                      if (events.isEmpty)
                        _buildEmptyTabResults(context, 'events')
                      else
                        ...events.map((e) => EventCard(event: e)),
                    ],
                  ],
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyTabResults(BuildContext context, String type) {
    final colors = context.faithColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 64.h),
      child: Center(
        child: Text(
          'No $type found matching your query.',
          style: TextStyle(color: colors.mutedText, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildSearchTabs(BuildContext context, int activeTab) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          _buildSearchTabItem(context, 'All', 0, activeTab == 0),
          _buildSearchTabItem(context, 'Posts', 1, activeTab == 1),
          _buildSearchTabItem(context, 'Events', 2, activeTab == 2),
        ],
      ),
    );
  }

  Widget _buildSearchTabItem(BuildContext context, String title, int index, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<HomeSearchBloc>().add(SearchTabChanged(index));
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchShimmerPlaceholder(BuildContext context) {
    final fill = faithShimmerFill(context);
    return FaithShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 40.h, fill: fill),
          SizedBox(height: 24.h),
          _shimmerBox(height: 180.h, fill: fill),
          SizedBox(height: 16.h),
          _shimmerBox(height: 220.h, fill: fill),
        ],
      ),
    );
  }
}
