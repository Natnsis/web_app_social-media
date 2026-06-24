import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Syncfusion spline area chart card for profile analytics screens.
class ProfileSplineAreaChartCard extends StatelessWidget {
  final String title;
  final String? trailingLabel;
  final String? subtitle;
  final List<GrowthTrendPoint> points;
  final String tooltipFormat;
  final Widget? headerTrailing;
  final String chartKeySuffix;

  const ProfileSplineAreaChartCard({
    super.key,
    required this.title,
    this.trailingLabel,
    this.subtitle,
    required this.points,
    this.tooltipFormat = 'point.y',
    this.headerTrailing,
    this.chartKeySuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final axisMax = maxValue <= 0 ? 100.0 : maxValue * 1.15;

    final labelStyle = TextStyle(
      color: DarkTheme.feedMutedText,
      fontSize: 10.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );

    return AppSurfaceCard(
      borderRadius: 24,
      padding: EdgeInsets.fromLTRB(8.w, 18.h, 8.w, 8.h),
      backgroundColor: DarkTheme.feedCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                color: DarkTheme.feedMutedText,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (headerTrailing != null) headerTrailing!,
                    if (trailingLabel != null)
                      Text(
                        trailingLabel!,
                        style: GoogleFonts.inter(
                          color: DarkTheme.feedMutedText,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 190.h,
            child: SfCartesianChart(
              key: ValueKey('spline-$chartKeySuffix-${points.length}'),
              backgroundColor: Colors.transparent,
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: labelStyle,
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: axisMax,
                isVisible: false,
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              series: <CartesianSeries<GrowthTrendPoint, String>>[
                SplineAreaSeries<GrowthTrendPoint, String>(
                  dataSource: points,
                  xValueMapper: (point, _) => point.label,
                  yValueMapper: (point, _) => point.value,
                  splineType: SplineType.cardinal,
                  cardinalSplineTension: 0.4,
                  animationDuration: 900,
                  borderDrawMode: BorderDrawMode.top,
                  borderColor: Colors.white.withValues(alpha: 0.92),
                  borderWidth: 2.5,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: tooltipFormat,
                header: '',
                color: DarkTheme.feedTagBackground,
                textStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
              ),
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipSettings: InteractiveTooltip(
                  enable: true,
                  format: tooltipFormat,
                ),
                lineColor: DarkTheme.brandBlue.withValues(alpha: 0.5),
                lineWidth: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
