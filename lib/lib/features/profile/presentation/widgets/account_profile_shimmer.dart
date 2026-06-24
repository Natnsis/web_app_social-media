import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Skeleton for [AccountProfilePage] while profile or saved feed loads.
class AccountProfileShimmer extends StatelessWidget {
  final bool includeHeader;

  const AccountProfileShimmer({
    super.key,
    this.includeHeader = true,
  });

  /// Feed-only placeholders (profile header already visible).
  static List<Widget> feedSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: FaithShimmer(
          child: AccountProfileFeedShimmer(fill: faithShimmerFill(context)),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final fill = faithShimmerFill(context);

    return FaithShimmer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          if (includeHeader) ..._headerSlivers(fill),
          SliverToBoxAdapter(
            child: AccountProfileFeedShimmer(fill: fill),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 88.h)),
        ],
      ),
    );
  }

  static List<Widget> _headerSlivers(Color fill) {
    return [
      SliverToBoxAdapter(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _ShimmerCircle(size: 60.r, fill: fill),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(height: 16.h, width: 140.w, radius: 8, fill: fill),
                        SizedBox(height: 8.h),
                        _ShimmerBox(height: 12.h, width: 100.w, radius: 6, fill: fill),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _ShimmerBox(height: 180.h, width: double.infinity, radius: 20, fill: fill),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

/// Saved-tab feed blocks (verse, posts, grid).
class AccountProfileFeedShimmer extends StatelessWidget {
  final Color fill;

  const AccountProfileFeedShimmer({super.key, required this.fill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          _ShimmerBox(height: 16.h, width: 120.w, radius: 8, fill: fill),
          SizedBox(height: 16.h),
          SizedBox(
            height: 160.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (_, __) => _ShimmerBox(
                height: 160.h,
                width: 120.w,
                radius: 16,
                fill: fill,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          _ShimmerBox(height: 16.h, width: 160.w, radius: 8, fill: fill),
          SizedBox(height: 16.h),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 6,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, __) => Container(
              height: 90.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  _ShimmerCircle(size: 50.r, fill: fill),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ShimmerBox(height: 14.h, width: 180.w, radius: 8, fill: fill),
                      SizedBox(height: 8.h),
                      _ShimmerBox(height: 12.h, width: 120.w, radius: 6, fill: fill),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double radius;
  final double? width;
  final Color fill;

  const _ShimmerBox({
    required this.height,
    required this.radius,
    required this.fill,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;
  final Color fill;

  const _ShimmerCircle({required this.size, required this.fill});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
    );
  }
}
