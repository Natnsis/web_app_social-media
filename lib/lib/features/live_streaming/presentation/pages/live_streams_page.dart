import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/gift/presentation/navigation/gift_navigation.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_bloc.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_event.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_state.dart';
import 'package:faithconnect/features/live_streaming/presentation/widgets/live_tiktok_feed_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/live_streaming/domain/repositories/station_repository.dart';

/// TikTok-style vertical live feed.
class LiveStreamsPage extends StatefulWidget {
  const LiveStreamsPage({super.key});

  @override
  State<LiveStreamsPage> createState() => _LiveStreamsPageState();
}

class _LiveStreamsPageState extends State<LiveStreamsPage> {
  late final PageController _pageController;
  int _visibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<LiveStreamBloc>().add(const LiveStreamsRequested());
  }

  Future<void> _handleGoLive() async {
    final repo = sl<StationRepository>();
    final stationsResult = await repo.getStations();

    await stationsResult.fold((failure) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Error'),
          content: Text(failure.message),
          actions: [
            TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK')),
          ],
        ),
      );
    }, (stations) async {
      if (!mounted) return;
      if (stations.isEmpty) {
        // Prompt to create a station using sample payload
        final create = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('No Station Found'),
            content: const Text('You need a station before you can create a livestream. Create a station now with sample data?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Create')),
            ],
          ),
        );

        if (create == true) {
          final createRes = await repo.createStation(
            name: 'Apostolic Church',
            description: 'Test mode',
            type: 'tv',
          );

          createRes.fold((f) async {
            if (!mounted) return;
            await showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Create failed'),
                content: Text(f.message),
                actions: [
                  TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK')),
                ],
              ),
            );
          }, (station) {
            if (!mounted) return;
            context.push(RoutesConstant.goLive);
          });
        }
      } else {
        context.push(RoutesConstant.goLive);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final canStartLive = context.readRoleAccess().showCreateActions;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<LiveStreamBloc, LiveStreamState>(
        buildWhen: (previous, current) {
          if (previous.runtimeType != current.runtimeType) return true;
          if (previous is LiveStreamsLoaded && current is LiveStreamsLoaded) {
            return previous.streams.length != current.streams.length;
          }
          return true;
        },
        builder: (context, state) {
          if (state is LiveStreamLoading) {
            return const _LiveFeedLoading();
          }

          if (state is LiveStreamFailure) {
            return _LiveFeedError(
              message: state.message,
              onRetry: () => context
                  .read<LiveStreamBloc>()
                  .add(const LiveStreamsRequested()),
            );
          }

          if (state is LiveStreamsLoaded) {
            if (state.streams.isEmpty) {
              return _LiveFeedEmpty(
                canStartLive: canStartLive,
                onGoLive: canStartLive
                    ? () => context.push(RoutesConstant.goLive)
                    : null,
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: state.streams.length,
                  onPageChanged: (index) => setState(() => _visibleIndex = index),
                  itemBuilder: (context, index) {
                    final stream = state.streams[index];
                    return BlocProvider(
                      create: (context) => sl<LiveStreamBloc>(),
                      child: LiveTikTokFeedItem(
                        key: ValueKey(stream.id),
                        stream: stream,
                        feedIndex: index,
                        isActive: index == _visibleIndex,
                        onClose: canPop ? () => context.pop() : null,
                        onGift: () => GiftNavigation.openLiveGiftSheet(
                          context,
                          streamId: stream.id,
                          hostName: stream.hostName,
                        ),
                      ),
                    );
                  },
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      children: [
                        // if (canPop)
                        //   IconCircleButton(
                        //     icon: Iconsax.arrow_left,
                        //     backgroundColor: Colors.black.withValues(alpha: 0.45),
                        //     onPressed: () => context.pop(),
                        //   )
                        // else
                        //   const SizedBox.shrink(),
                        const Spacer(),
                        // if (canStartLive)
                        //   _GoLiveChip(
                        //     onTap: _handleGoLive,
                        //   ),
                      ],
                    ),
                  ),
                ),
                if (state.streams.length > 1)
                  Positioned(
                    right: 10.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _FeedPageIndicator(
                        count: state.streams.length,
                        index: _visibleIndex,
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// class _GoLiveChip extends StatelessWidget {
//   final VoidCallback onTap;

//   const _GoLiveChip({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(24.r),
//         child: Ink(
//           padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//           decoration: BoxDecoration(
//             color: DarkTheme.redDanger500.withValues(alpha: 0.9),
//             borderRadius: BorderRadius.circular(24.r),
//             boxShadow: [
//               BoxShadow(
//                 color: DarkTheme.redDanger500.withValues(alpha: 0.35),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Iconsax.video, color: Colors.white, size: 18.r),
//               SizedBox(width: 6.w),
//               Text(
//                 'Go Live',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _FeedPageIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _FeedPageIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: EdgeInsets.symmetric(vertical: 3.h),
            width: 3.w,
            height: i == index ? 18.h : 8.h,
            decoration: BoxDecoration(
              color: i == index
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
      ],
    );
  }
}

class _LiveFeedLoading extends StatelessWidget {
  const _LiveFeedLoading();

  @override
  Widget build(BuildContext context) {
    return FaithShimmer(
      child: ColoredBox(color: faithShimmerScreenFill(context)),
    );
  }
}

class _LiveFeedError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LiveFeedError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            AppSpacing.v16,
            PrimaryButton(
              text: 'Retry',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveFeedEmpty extends StatelessWidget {
  final bool canStartLive;
  final VoidCallback? onGoLive;

  const _LiveFeedEmpty({
    required this.canStartLive,
    this.onGoLive,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.video, color: Colors.white38, size: 56.r),
            AppSpacing.v16,
            Text(
              canStartLive
                  ? 'No one is live right now'
                  : 'No one is live right now.\nPull to refresh when a stream starts.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if (onGoLive != null) ...[
              AppSpacing.v16,
              PrimaryButton(text: 'Go Live', onPressed: onGoLive),
            ],
          ],
        ),
      ),
    );
  }
}
