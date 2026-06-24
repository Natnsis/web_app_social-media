import 'package:faithconnect/core/core.dart';
import 'package:intl/intl.dart';
import 'package:faithconnect/features/analytics/domain/entities/analytics_entity.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/campaign/presentation/navigation/campaign_navigation.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_state.dart';
import 'package:faithconnect/features/profile/presentation/widgets/account_settings_section.dart';
import 'package:faithconnect/features/profile/presentation/widgets/account_settings_stat_card.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:faithconnect/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:faithconnect/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:faithconnect/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:faithconnect/features/profile/presentation/widgets/analytics_shimmer.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  bool _notificationsEnabled = true;
  int? _followingCount;
  int _activeTabIndex = 1;

  String _getTabLabel() {
    switch (_activeTabIndex) {
      case 0: return 'TOTAL THIS WEEK';
      case 1: return 'TOTAL THIS MONTH';
      case 2: return 'TOTAL THIS YEAR';
      case 3: return 'TOTAL OF ALL TIME';
      default: return 'TOTAL';
    }
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<AccountProfileBloc>().state;
    if (state is! AccountProfileLoaded) {
      context.read<AccountProfileBloc>().add(const AccountProfileRequested());
    }
    _loadFollowingCount();
  }

  Future<void> _loadFollowingCount() async {
    final result = await sl<ChurchService>().getFollowingChurches(limit: 1);
    if (!mounted) return;
    result.fold(
      (_) {},
      (page) => setState(() => _followingCount = page.meta.total),
    );
  }

  void _showComingSoon(String label) {
    showInfo(context, '$label coming soon');
  }

  Widget _buildTab(String title, int index) {
    final isActive = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTabIndex = index;
          });
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

  Widget _buildEngagementChart(OverviewEntity overview) {
    final double maxVal = [
      overview.followerCount,
      overview.postCount,
      overview.activeGroupCount,
      overview.activeCampaigns,
    ].fold(0.0, (prev, e) => e > prev ? e.toDouble() : prev);
    final double maxY = maxVal == 0 ? 10.0 : maxVal * 1.3;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                );
              },
            ),
          ),
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 32.h,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = GoogleFonts.inter(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Followers'; break;
                    case 1: text = 'Posts'; break;
                    case 2: text = 'Groups'; break;
                    case 3: text = 'Campaigns'; break;
                    default: text = ''; break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.h,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: overview.followerCount.toDouble(), color: context.faithColors.brandSky, width: 16.w)]),
            BarChartGroupData(x: 1, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: overview.postCount.toDouble(), color: context.faithColors.brandSky, width: 16.w)]),
            BarChartGroupData(x: 2, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: overview.activeGroupCount.toDouble(), color: context.faithColors.brandSky, width: 16.w)]),
            BarChartGroupData(x: 3, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: overview.activeCampaigns.toDouble(), color: context.faithColors.brandSky, width: 16.w)]),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialChart(OverviewEntity overview) {
    final double maxVal = [
      overview.totalCampaignRaisedEtb,
      overview.giftsReceivedEtb,
      overview.wallet.balanceEtb,
    ].fold(0.0, (prev, e) => e > prev ? e.toDouble() : prev);
    final double maxY = maxVal == 0 ? 10.0 : maxVal * 1.3;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                );
              },
            ),
          ),
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 32.h,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final style = GoogleFonts.inter(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Raised'; break;
                    case 1: text = 'Gifts'; break;
                    case 2: text = 'Balance'; break;
                    default: text = ''; break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.h,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: overview.totalCampaignRaisedEtb.toDouble(), color: const Color(0xFF00C853), width: 16.w)]),
            BarChartGroupData(x: 1, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: overview.giftsReceivedEtb.toDouble(), color: const Color(0xFF00C853), width: 16.w)]),
            BarChartGroupData(x: 2, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: overview.wallet.balanceEtb.toDouble(), color: const Color(0xFF00C853), width: 16.w)]),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String initials, String name, String subtitle, String amount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: const Color(0xFFE5E7EB),
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00C853),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ProfileHubAppBar(
        title: 'Analytics',
        useWhiteInDarkMode: true,
      ),
      body: BlocBuilder<AccountProfileBloc, AccountProfileState>(
        builder: (context, state) {
          if (state is AccountProfileLoading) {
            return const AnalyticsShimmer();
          }

          if (state is AccountProfileFailure) {
            return Center(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.primaryText),
                    ),
                    AppSpacing.v16,
                    PrimaryButton.feedAction(
                      text: 'Retry',
                      onPressed: () => context.read<AccountProfileBloc>().add(
                        const AccountProfileRequested(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! AccountProfileLoaded) {
            return const SizedBox.shrink();
          }

          return RoleGuardBuilder(
  builder: (context, access) {
    final userRoles = state.currentUser?.roles ?? const <String>[];
    final effective = RoleGuardAccess.resolve(
      shellRoles: access.roles,
      profileRoles: userRoles,
      shellIsChurchMode: access.isChurchMode,
    );
              return BlocProvider<AnalyticsBloc>(
                create: (_) => sl<AnalyticsBloc>()..add(AnalyticsRequested(state.profile.id)),
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  builder: (context, analyticsState) {
                    if (analyticsState is AnalyticsLoading) {
                      return const AnalyticsShimmer();
                    } else if (analyticsState is AnalyticsError) {
                      return Center(child: Text(analyticsState.message, style: TextStyle(color: context.faithColors.error)));
                    } else if (analyticsState is AnalyticsLoaded) {
                      final overview = analyticsState.analytics.overview;
                      final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
                      
                      return ListView(
                        padding: EdgeInsets.only(bottom: 32.h),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          SizedBox(height: 24.h),
                          Text(
                            _getTabLabel(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: context.faithColors.mutedText,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${formatter.format(overview.giftsReceivedEtb)} ETB',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E24),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Row(
                              children: [
                                _buildTab('Week', 0),
                                _buildTab('Month', 1),
                                _buildTab('Year', 2),
                                _buildTab('All', 3),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Engagement Overview
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.02),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Engagement Overview',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                _buildEngagementChart(overview),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Financial Overview
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.02),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Financial Overview',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                _buildFinancialChart(overview),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Active Campaigns',
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'See All',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.faithColors.brandSky,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (analyticsState.analytics.campaigns.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              child: Text(
                                'No active campaigns at the moment.',
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 14.sp),
                              ),
                            )
                          else
                            ...analyticsState.analytics.campaigns.map((campaign) {
                              final title = campaign['title']?.toString() ?? 'Unknown';
                              final initials = title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?';
                              final balance = campaign['currentBalance'] ?? 0;
                              final goal = campaign['goalAmount'] ?? 0;
                              final percent = campaign['percentComplete'] ?? 0;
                              return _buildTransactionItem(
                                initials,
                                title,
                                'Goal: ${formatter.format(goal)} ETB • $percent% complete',
                                '+${formatter.format(balance)} ETB',
                              );
                            }),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

