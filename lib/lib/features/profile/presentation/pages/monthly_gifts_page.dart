import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:faithconnect/features/profile/presentation/bloc/monthly_gifts_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/monthly_gifts_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/monthly_gifts_state.dart';
import 'package:faithconnect/features/profile/presentation/widgets/gift_transaction_tile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/gifts_growth_chart_card.dart';
import 'package:faithconnect/features/profile/presentation/widgets/gifts_period_selector.dart';
import 'package:faithconnect/features/profile/presentation/widgets/gifts_summary_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyGiftsPage extends StatefulWidget {
  const MonthlyGiftsPage({super.key});

  @override
  State<MonthlyGiftsPage> createState() => _MonthlyGiftsPageState();
}

class _MonthlyGiftsPageState extends State<MonthlyGiftsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MonthlyGiftsBloc>().add(const MonthlyGiftsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ProfileHubAppBar(title: 'Monthly Gifts'),
      body: BlocBuilder<MonthlyGiftsBloc, MonthlyGiftsState>(
        builder: (context, state) {
          if (state is MonthlyGiftsLoading) {
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

          if (state is MonthlyGiftsFailure) {
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
                          .read<MonthlyGiftsBloc>()
                          .add(const MonthlyGiftsRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! MonthlyGiftsLoaded) {
            return const SizedBox.shrink();
          }

          return _MonthlyGiftsBody(summary: state.summary);
        },
      ),
    );
  }
}

class _MonthlyGiftsBody extends StatelessWidget {
  final GiftSummary summary;

  const _MonthlyGiftsBody({required this.summary});

  @override
  Widget build(BuildContext context) {
    final transactions = summary.recentTransactions;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        GiftsSummaryHeader(summary: summary),
        AppSpacing.v24,
        GiftsPeriodSelector(
          selected: summary.period,
          onChanged: (period) => context
              .read<MonthlyGiftsBloc>()
              .add(MonthlyGiftsPeriodChanged(period)),
        ),
        AppSpacing.v20,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: GiftsGrowthChartCard(
            key: ValueKey('chart-${summary.period.name}'),
            summary: summary,
          ),
        ),
        AppSpacing.v24,
        Row(
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => showInfo(context, 'Full history coming soon'),
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  color: DarkTheme.brandBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.v8,
        AppSurfaceCard(
          borderRadius: 20,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          backgroundColor: DarkTheme.feedCardBackground,
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++)
                GiftTransactionTile(
                  transaction: transactions[i],
                  showDivider: i < transactions.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
