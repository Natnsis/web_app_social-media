import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/church/presentation/bloc/following_bloc.dart';
import 'package:faithconnect/features/church/presentation/bloc/following_event.dart';
import 'package:faithconnect/features/church/presentation/bloc/following_state.dart';
import 'package:faithconnect/features/church/domain/entities/following_church.dart';
import 'package:faithconnect/features/church/presentation/widgets/following_church_tile.dart';
import 'package:faithconnect/features/church/presentation/widgets/unfollow_church_dialog.dart';
import 'package:faithconnect/features/church/presentation/widgets/following_summary_header.dart';
import 'package:faithconnect/features/profile/application/profile_service.dart';
import 'package:faithconnect/features/profile/presentation/widgets/gifts_period_selector.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_spline_area_chart_card.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FollowingBloc(
        churchService: sl<ChurchService>(),
        profileService: sl<ProfileService>(),
      ),
      child: const _FollowingView(),
    );
  }
}

class _FollowingView extends StatefulWidget {
  const _FollowingView();

  @override
  State<_FollowingView> createState() => _FollowingViewState();
}

class _FollowingViewState extends State<_FollowingView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<FollowingBloc>().add(const FollowingLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ProfileHubAppBar(
        title: 'Following',
        useWhiteInDarkMode: true,
      ),
      body: BlocConsumer<FollowingBloc, FollowingState>(
        listener: (context, state) {
          if (state is FollowingLoaded && state.errorMessage != null) {
            showWarning(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state is FollowingLoading) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GiftsPeriodSelector(
                    selected: state.period,
                    onChanged: (_) {},
                  ),
                ),
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: colors.brandBlue),
                  ),
                ),
              ],
            );
          }

          if (state is FollowingFailure) {
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
                          .read<FollowingBloc>()
                          .add(const FollowingRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! FollowingLoaded) {
            return const SizedBox.shrink();
          }

          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
            children: [
              FollowingSummaryHeader(summary: state.analytics),
              AppSpacing.v20,
              GiftsPeriodSelector(
                selected: state.analytics.period,
                onChanged: (period) => context
                    .read<FollowingBloc>()
                    .add(FollowingPeriodChanged(period)),
              ),
              AppSpacing.v20,
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: ProfileSplineAreaChartCard(
                  key: ValueKey('following-chart-${state.analytics.period.name}'),
                  title: 'Growth Trend',
                  trailingLabel: state.analytics.periodRangeLabel,
                  points: state.analytics.trendPoints,
                  tooltipFormat: 'point.y',
                  chartKeySuffix: 'following-${state.analytics.period.name}',
                ),
              ),
              AppSpacing.v24,
              Text(
                'Churches You Follow',
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              if (state.churches.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'You are not following any churches yet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 14.sp,
                    ),
                  ),
                )
              else ...[
                ...state.churches.asMap().entries.map((entry) {
                  final church = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: FollowingChurchTile(
                      church: church,
                      onTap: () => context.pushNamed(
                        RoutesConstant.churchProfile,
                        pathParameters: {'id': church.id},
                      ),
                      onUnfollow: () => _confirmUnfollow(context, church),
                    ),
                  );
                }),
                if (state.isLoadingMore)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Center(
                      child: CircularProgressIndicator(color: colors.brandBlue),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmUnfollow(
    BuildContext context,
    FollowingChurch church,
  ) async {
    final confirmed = await showUnfollowChurchDialog(
      context,
      churchName: church.name,
    );
    if (!confirmed || !context.mounted) return;
    context.read<FollowingBloc>().add(FollowingUnfollowToggled(church.id));
  }
}
