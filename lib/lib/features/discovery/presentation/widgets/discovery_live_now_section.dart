import 'package:faithconnect/features/discovery/domain/entities/discovery_live_item.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_live_card.dart';
import 'package:faithconnect/features/discovery/presentation/widgets/discovery_section_header.dart';
import 'package:faithconnect/features/live_streaming/presentation/navigation/live_stream_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscoveryLiveNowSection extends StatelessWidget {
  final List<DiscoveryLiveItem> liveNow;

  const DiscoveryLiveNowSection({
    super.key,
    required this.liveNow,
  });

  @override
  Widget build(BuildContext context) {
    if (liveNow.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DiscoverySectionHeader(
          title: 'Live Now',
          actionLabel: 'See all',
          onAction: () => LiveStreamNavigation.openHub(context),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 252.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: liveNow.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final live = liveNow[index];
              return DiscoveryLiveCard(
                item: live,
                onTap: () => LiveStreamNavigation.openWatch(
                  context,
                  live.streamId,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
