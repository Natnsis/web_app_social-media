import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/subscribers_summary.dart';
import 'package:faithconnect/features/profile/presentation/bloc/subscribers_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/subscribers_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/subscribers_state.dart';
import 'package:faithconnect/features/profile/presentation/widgets/gifts_period_selector.dart';
import 'package:faithconnect/features/profile/presentation/widgets/new_member_tile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_spline_area_chart_card.dart';
import 'package:faithconnect/features/profile/presentation/widgets/subscribers_summary_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscribersPage extends StatefulWidget {
  const SubscribersPage({super.key});

  @override
  State<SubscribersPage> createState() => _SubscribersPageState();
}

class _SubscribersPageState extends State<SubscribersPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscribersBloc>().add(const SubscribersRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ProfileHubAppBar(title: 'Subscribers'),
      body: BlocBuilder<SubscribersBloc, SubscribersState>(
        builder: (context, state) {
          if (state is SubscribersLoading) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GiftsPeriodSelector(
                    selected: state.period,
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

          if (state is SubscribersFailure) {
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
                          .read<SubscribersBloc>()
                          .add(const SubscribersRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! SubscribersLoaded) {
            return const SizedBox.shrink();
          }

          return _SubscribersBody(summary: state.summary);
        },
      ),
    );
  }
}

class _SubscribersBody extends StatelessWidget {
  final SubscribersSummary summary;

  const _SubscribersBody({required this.summary});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        SubscribersSummaryHeader(summary: summary),
        AppSpacing.v20,
        GiftsPeriodSelector(
          selected: summary.period,
          onChanged: (period) => context
              .read<SubscribersBloc>()
              .add(SubscribersPeriodChanged(period)),
        ),
        AppSpacing.v20,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: ProfileSplineAreaChartCard(
            key: ValueKey('subs-chart-${summary.period.name}'),
            title: 'Growth Trend',
            trailingLabel: summary.periodRangeLabel,
            points: summary.trendPoints,
            tooltipFormat: 'point.y',
            chartKeySuffix: 'subs-${summary.period.name}',
          ),
        ),
        AppSpacing.v24,
        Row(
          children: [
            Text(
              'New Members',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'See Members',
              onPressed: () => showInfo(context, 'Member directory coming soon'),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              paddingVertical: 10,
              paddingHorizontal: 16,
              fontSize: 13.sp,
              radiusVariant: ButtonRadius.full,
            ),
          ],
        ),
        AppSpacing.v12,
        ...summary.newMembers.map(
          (member) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: NewMemberTile(member: member),
          ),
        ),
      ],
    );
  }
}
