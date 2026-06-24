import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/discovery/domain/entities/discovery_nearby_church.dart';
import 'package:faithconnect/features/discovery/domain/entities/nearby_churches_filter.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_bloc.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_event.dart';
import 'package:faithconnect/features/discovery/presentation/bloc/nearby_state.dart';
import 'package:faithconnect/features/discovery/presentation/navigation/discovery_navigation.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_nearby_card.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_nearby_shimmer.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/nearby_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Horizontal "Nearby" churches row — shared by Discovery and Home.
class DiscoveryNearbySection extends StatefulWidget {
  static const double sectionTitleGap = 12;
  static const double listHeight = 130;
  static const double cardWidth = 240;
  static const double cardGap = 12;
  final double topSpacing;
  final double bottomSpacing;
  final bool showFilterAction;
  final bool alwaysShowSection;

  const DiscoveryNearbySection({
    super.key,
    this.topSpacing = 20,
    this.bottomSpacing = 0,
    this.showFilterAction = false,
    this.alwaysShowSection = false,
  });

  @override
  State<DiscoveryNearbySection> createState() => _DiscoveryNearbySectionState();
}

class _DiscoveryNearbySectionState extends State<DiscoveryNearbySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  void _ensureLoaded() {
    if (!mounted) return;
    final state = context.read<NearbyBloc>().state;
    if (widget.alwaysShowSection) {
      context.read<NearbyBloc>().add(
        const NearbyRefreshed(useHomePreview: true),
      );
    } else if (state is NearbyInitial || state is NearbyFailure) {
      context.read<NearbyBloc>().add(const NearbyRequested());
    }
  }

  void _openChurchProfile(String id) {
    context.pushNamed(RoutesConstant.churchProfile, pathParameters: {'id': id});
  }

  void _openFilters(NearbyChurchesFilter current) {
    NearbyFilterSheet.show(
      context,
      current: current,
      onApply: (next) {
        context.read<NearbyBloc>().add(NearbyFilterChanged(next));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NearbyBloc, NearbyState>(
      listenWhen: (prev, next) => next is NearbyFailure,
      listener: (context, state) {
        if (state is NearbyFailure) {
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              context.read<NearbyBloc>().add(
                widget.alwaysShowSection
                    ? const NearbyRefreshed(useHomePreview: true)
                    : const NearbyRequested(),
              );
            }
          });
        }
      },
      buildWhen: (prev, next) =>
          prev.runtimeType != next.runtimeType ||
          (next is NearbyLoaded && prev is NearbyLoaded
              ? next.result != prev.result
              : true),
      builder: (context, state) {
        final filter = _filterFromState(state);
        final churches = _churchesFromState(state);
        final isLoading = state is NearbyLoading || state is NearbyInitial;
        final isRefreshing = state is NearbyRefreshing;
        final failure = state is NearbyFailure ? state.message : null;

        if (!widget.alwaysShowSection &&
            !isLoading &&
            !isRefreshing &&
            failure == null &&
            churches.isEmpty) {
          return const SizedBox.shrink();
        }

        return _wrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text(
                      'Nearby',
                      style: GoogleFonts.inter(
                        color: context.faithColors.primaryText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.showFilterAction) ...[
                      SizedBox(width: 10.w),
                      _RadiusChip(
                        label: filter.radiusLabel,
                        onTap: () => _openFilters(filter),
                      ),
                    ],
                    const Spacer(),
                    TextButton(
                      onPressed: () => DiscoveryNavigation.openNearby(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: context.faithColors.brandBlue,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        overlayColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(),
                        textStyle: const TextStyle(decoration: TextDecoration.none),
                      ),
                      child: Text(
                        'See all',
                        style: GoogleFonts.inter(
                          color: context.faithColors.brandBlue,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isRefreshing)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: context.faithColors.brandBlue,
                    backgroundColor:
                        context.faithColors.brandBlue.withValues(alpha: 0.15),
                  ),
                ),
              SizedBox(height: DiscoveryNearbySection.sectionTitleGap.h),
              SizedBox(
                height: DiscoveryNearbySection.listHeight.h,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildBody(
                    context,
                    key: ValueKey(isLoading ? 'loading' : failure != null ? 'failure' : 'loaded_${churches.length}'),
                    isLoading: isLoading,
                    failure: failure,
                    churches: churches,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  List<DiscoveryNearbyChurch> _churchesFromState(NearbyState state) {
    return switch (state) {
      NearbyLoaded(:final result) => result.churches,
      NearbyRefreshing(:final previous) => previous.churches,
      _ => const [],
    };
  }

  Widget _buildBody(
    BuildContext context, {
    required Key key,
    required bool isLoading,
    required String? failure,
    required List<DiscoveryNearbyChurch> churches,
  }) {
    if (isLoading || failure != null) {
      return DiscoveryNearbyShimmer(key: key);
    }

    if (churches.isEmpty) {
      return _EmptyNearby(
        key: key,
        onOpenNearby: () => DiscoveryNavigation.openNearby(context),
      );
    }

    return ListView.separated(
      key: key,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: churches.length,
      separatorBuilder: (_, _) =>
          SizedBox(width: DiscoveryNearbySection.cardGap.w),
      itemBuilder: (context, index) {
        final church = churches[index];
        return SizedBox(
          width: DiscoveryNearbySection.cardWidth.w,
          height: DiscoveryNearbySection.listHeight.h,
          child: Align(
            alignment: Alignment.center,
            child: DiscoveryNearbyCard(
              church: church,
              onTap: () => _openChurchProfile(church.id),
              onFollow: () => context.read<NearbyBloc>().add(
                    NearbyFollowToggled(
                      churchId: church.id,
                      follow: !church.isFollowing,
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _wrap({required Widget child}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.topSpacing > 0) SizedBox(height: widget.topSpacing.h),
        child,
        if (widget.bottomSpacing > 0) SizedBox(height: widget.bottomSpacing.h),
      ],
    );
  }
}

class _RadiusChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RadiusChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    return Material(
      color: colors.brandBlue.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.filter, size: 14.r, color: colors.brandBlue),
              SizedBox(width: 4.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: colors.brandBlue,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNearby extends StatelessWidget {
  final VoidCallback onOpenNearby;

  const _EmptyNearby({super.key, required this.onOpenNearby});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No churches found nearby yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.faithColors.secondaryText,
                  ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: onOpenNearby,
              child: const Text('Explore on map'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InlineRetry({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.faithColors.secondaryText,
                  ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
