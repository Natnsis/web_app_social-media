import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_event.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_state.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_nearby_shimmer.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_app_bar.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/nearby_church_tile.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/nearby_churches_map.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/nearby_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NearbyChurchesPage extends StatefulWidget {
  const NearbyChurchesPage({super.key});

  @override
  State<NearbyChurchesPage> createState() => _NearbyChurchesPageState();
}

class _NearbyChurchesPageState extends State<NearbyChurchesPage> {
  @override
  void initState() {
    super.initState();
    context.read<NearbyBloc>().add(const NearbyListRequested());
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
      context.read<NearbyBloc>().add(const NearbyLoadMore());
    }
    return false;
  }

  void _openFilters() {
    final bloc = context.read<NearbyBloc>();
    final filter = switch (bloc.state) {
      NearbyLoaded(:final result) => result.filter,
      NearbyRefreshing(:final filter) => filter,
      NearbyLoading(:final filter) => filter,
      _ => bloc.filter,
    };

    NearbyFilterSheet.show(
      context,
      current: filter,
      onApply: (next) {
        context.read<NearbyBloc>().add(
              NearbyFilterChanged(
                NearbyChurchesFilter.forListPage(radiusKm: next.clampedRadiusKm),
              ),
            );
      },
    );
  }

  void _openChurchProfile(String id) {
    context.pushNamed(
      RoutesConstant.churchProfile,
      pathParameters: {'id': id},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: DiscoveryAppBar(
        title: 'Nearby',
        showBack: true,
        trailingActions: [
          BlocBuilder<NearbyBloc, NearbyState>(
            buildWhen: (a, b) => _filterFromState(a) != _filterFromState(b),
            builder: (context, state) {
              final filter = _filterFromState(state);
              return IconButton(
                tooltip: 'Search radius (${filter.radiusLabel})',
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.filter, color: Colors.white, size: 20.r),
                    SizedBox(width: 4.w),
                    Text(
                      filter.radiusLabel,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onPressed: _openFilters,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NearbyBloc, NearbyState>(
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              NearbyChurchesMap(
                churches: state.churches,
                meta: state.meta,
                onChurchTap: _openChurchProfile,
                bottomPadding: MediaQuery.of(context).size.height * 0.40,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.40,
                minChildSize: 0.25,
                maxChildSize: 0.92,
                snap: true,
                builder: (context, scrollController) {
                  return _buildSheetContent(context, state, scrollController);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  NearbyChurchesFilter _filterFromState(NearbyState state) {
    return switch (state) {
      NearbyLoaded(:final result) => result.filter,
      NearbyRefreshing(:final filter) => filter,
      NearbyLoading(:final filter) => filter,
      _ => context.read<NearbyBloc>().filter,
    };
  }

  Widget _buildSheetContent(BuildContext context, NearbyState state, ScrollController scrollController) {
    if (state is NearbyLoading || state is NearbyInitial) {
      return _sheetContainer(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              _sheetHandle(),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                child: Text(
                  'Finding churches near you...',
                  style: GoogleFonts.inter(
                    color: DarkTheme.feedMutedText,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(
                height: 170.h,
                child: const DiscoveryNearbyShimmer(),
              ),
            ],
          ),
        ),
      );
    }

    if (state is NearbyFailure) {
      return _sheetContainer(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              _sheetHandle(),
              SizedBox(height: 40.h),
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    AppSpacing.v16,
                    PrimaryButton.feedAction(
                      text: 'Try again',
                      onPressed: () =>
                          context.read<NearbyBloc>().add(const NearbyListRequested()),
                      width: 160.w,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final result = switch (state) {
      NearbyLoaded(:final result) => result,
      NearbyRefreshing(:final previous) => previous,
      NearbyPaginating(:final previous) => previous,
      _ => null,
    };

    if (result == null) return const SizedBox.shrink();

    final isRefreshing = state is NearbyRefreshing;
    final isPaginating = state is NearbyPaginating;

    return _sheetContainer(
      child: Column(
        children: [
          SizedBox(height: 10.h),
          _sheetHandle(),
          if (isRefreshing)
            LinearProgressIndicator(
              minHeight: 2,
              color: DarkTheme.brandBlue,
              backgroundColor: DarkTheme.brandBlue.withValues(alpha: 0.15),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.totalCount} Churches Found',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${result.areaLabel} · ${result.filter.radiusLabel}',
                  style: GoogleFonts.inter(
                    color: DarkTheme.feedMutedText,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: result.churches.isEmpty
                ? SingleChildScrollView(
                    controller: scrollController,
                    child: _emptyState(context),
                  )
                : RefreshIndicator(
                    color: DarkTheme.brandBlue,
                    onRefresh: () async {
                      context.read<NearbyBloc>().add(const NearbyListRequested());
                      await context.read<NearbyBloc>().stream.firstWhere(
                            (s) => s is! NearbyRefreshing,
                          );
                    },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: ListView.separated(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        itemCount: result.churches.length + (isPaginating ? 1 : 0),
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          if (index == result.churches.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: _NearbyChurchTileShimmer(fill: faithShimmerFill(context)),
                            );
                          }
                          final church = result.churches[index];
                          return AnimatedOpacity(
                            opacity: isRefreshing ? 0.72 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: NearbyChurchTile(
                              church: church,
                              onTap: () => _openChurchProfile(church.id),
                              onFollow: () =>
                                  context.read<NearbyBloc>().add(
                                        NearbyFollowToggled(
                                          churchId: church.id,
                                          follow: !church.isFollowing,
                                        ),
                                      ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.building,
              size: 48.r,
              color: DarkTheme.feedMutedText,
            ),
            SizedBox(height: 12.h),
            Text(
              'No churches in this radius',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try increasing the search distance.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: DarkTheme.feedMutedText,
                fontSize: 14.sp,
              ),
            ),
            AppSpacing.v16,
            PrimaryButton.feedAction(
              text: 'Adjust radius',
              onPressed: _openFilters,
              width: 180.w,
            ),
          ],
        ),
      ),
    );
  }



  Widget _sheetHandle() {
    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: DarkTheme.feedMutedText.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _sheetContainer({required Widget child, Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DarkTheme.feedCardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: child,
    );
  }
}

class _NearbyChurchTileShimmer extends StatelessWidget {
  final Color fill;

  const _NearbyChurchTileShimmer({required this.fill});

  @override
  Widget build(BuildContext context) {
    return FaithShimmer(
      child: Container(
        height: 80.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14.h,
                    width: double.infinity,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 12.h,
                    width: 120.w,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
