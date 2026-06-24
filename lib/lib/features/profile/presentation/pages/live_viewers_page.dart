import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/live_viewers_summary.dart';
import 'package:faithconnect/features/profile/presentation/bloc/live_viewers_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/live_viewers_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/live_viewers_state.dart';
import 'package:faithconnect/features/profile/presentation/widgets/live_viewers_peak_card.dart';
import 'package:faithconnect/features/profile/presentation/widgets/live_viewers_range_selector.dart';
import 'package:faithconnect/features/profile/presentation/widgets/live_viewers_retention_tile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_spline_area_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveViewersPage extends StatefulWidget {
  const LiveViewersPage({super.key});

  @override
  State<LiveViewersPage> createState() => _LiveViewersPageState();
}

class _LiveViewersPageState extends State<LiveViewersPage> {
  @override
  void initState() {
    super.initState();
    context.read<LiveViewersBloc>().add(const LiveViewersRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ProfileHubAppBar(title: 'Live Viewers'),
      body: BlocBuilder<LiveViewersBloc, LiveViewersState>(
        builder: (context, state) {
          if (state is LiveViewersLoading) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: LiveViewersRangeSelector(
                    selected: state.range,
                    onChanged: (_) {},
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: DarkTheme.brandBlue,
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is LiveViewersFailure) {
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
                          .read<LiveViewersBloc>()
                          .add(const LiveViewersRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! LiveViewersLoaded) {
            return const SizedBox.shrink();
          }

          return _LiveViewersBody(summary: state.summary);
        },
      ),
    );
  }
}

class _LiveViewersBody extends StatelessWidget {
  final LiveViewersSummary summary;

  const _LiveViewersBody({required this.summary});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        LiveViewersPeakCard(summary: summary),
        AppSpacing.v20,
        LiveViewersRangeSelector(
          selected: summary.range,
          onChanged: (range) => context
              .read<LiveViewersBloc>()
              .add(LiveViewersRangeChanged(range)),
        ),
        AppSpacing.v20,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: ProfileSplineAreaChartCard(
            key: ValueKey('live-chart-${summary.range.name}'),
            title: 'Viewer Activity',
            subtitle: summary.chartSubtitle,
            points: summary.activityPoints,
            tooltipFormat: 'point.y viewers',
            chartKeySuffix: 'live-${summary.range.name}',
            headerTrailing: Container(
              width: 10.r,
              height: 10.r,
              margin: EdgeInsets.only(top: 4.h, left: 8.w),
              decoration: const BoxDecoration(
                color: DarkTheme.greenSuccess500,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        AppSpacing.v12,
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => showInfo(context, 'Full report coming soon'),
            child: Text(
              'View Full Report',
              style: GoogleFonts.inter(
                color: DarkTheme.brandBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        AppSpacing.v16,
        LiveViewersRetentionTile(
          retention: summary.averageRetention,
          onTap: () => showInfo(context, 'Retention details coming soon'),
        ),
      ],
    );
  }
}
