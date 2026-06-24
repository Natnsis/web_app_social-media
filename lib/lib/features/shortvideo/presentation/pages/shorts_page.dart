import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/layout/shell_tab_scope.dart';
import 'package:faithconnect/features/shortvideo/presentation/navigation/shorts_navigation.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_bloc.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_event.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_state.dart';
import 'package:faithconnect/features/shortvideo/presentation/widgets/short_video_player_page.dart';
import 'package:faithconnect/features/shortvideo/presentation/widgets/shorts_feed_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  late final PageController _pageController;
  int _visibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<ShortsFeedBloc>().add(const ShortsFeedRequested());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _maybeRefreshAfterPublish() {
    if (!ShortsNavigation.takePendingFeedRefresh()) return;
    context.read<ShortsFeedBloc>().add(const ShortsFeedRequested());
  }

  @override
  Widget build(BuildContext context) {
    final tabIndexListenable = ShellTabScope.of(context)?.tabIndexListenable;
    if (tabIndexListenable == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeRefreshAfterPublish();
      });
      return _buildScaffold(context);
    }

    return ListenableBuilder(
      listenable: tabIndexListenable,
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybeRefreshAfterPublish();
        });
        return _buildScaffold(context);
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ShortsFeedBloc, ShortsFeedState>(
        buildWhen: (previous, current) {
          if (previous.runtimeType != current.runtimeType) return true;
          if (previous is ShortsFeedLoaded && current is ShortsFeedLoaded) {
            return previous.videos.length != current.videos.length;
          }
          return true;
        },
        builder: (context, state) {
          if (state is ShortsFeedLoading) {
            return const ShortsFeedShimmer();
          }

          if (state is ShortsFeedFailure) {
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
                          .read<ShortsFeedBloc>()
                          .add(const ShortsFeedRequested()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ShortsFeedLoaded && state.videos.isEmpty) {
            final canCreate = context.readRoleAccess().showCreateActions;
            return _ShortsFeedEmpty(
              onCreateShort: canCreate
                  ? () => context.push(RoutesConstant.newPost)
                  : null,
              onRefresh: () => context
                  .read<ShortsFeedBloc>()
                  .add(const ShortsFeedRequested()),
            );
          }

          if (state is! ShortsFeedLoaded) {
            return const SizedBox.shrink();
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: state.videos.length,
            onPageChanged: (index) {
              setState(() => _visibleIndex = index);
              context.read<ShortsFeedBloc>().add(ShortsPageChanged(index));
            },
            itemBuilder: (context, index) {
              final video = state.videos[index];
              return ShortVideoPlayerPage(
                video: video,
                index: index,
                isActive: index == _visibleIndex,
                onLikeTap: () => context
                    .read<ShortsFeedBloc>()
                    .add(ShortVideoLikeToggled(index)),
                onFollowTap: () => context
                    .read<ShortsFeedBloc>()
                    .add(ShortVideoFollowToggled(index)),
              );
            },
          );
        },
      ),
    );
  }
}

class _ShortsFeedEmpty extends StatelessWidget {
  final VoidCallback? onCreateShort;
  final VoidCallback onRefresh;

  const _ShortsFeedEmpty({
    this.onCreateShort,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.video_play, color: Colors.white38, size: 56.r),
            AppSpacing.v16,
            const Text(
              'No shorts yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.v8,
            const Text(
              'Be the first to share a short video with your community.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (onCreateShort != null) ...[
              AppSpacing.v24,
              PrimaryButton(
                text: 'Create Short',
                onPressed: onCreateShort,
              ),
              AppSpacing.v12,
            ] else
              AppSpacing.v24,
            PrimaryButton.feedAction(
              text: 'Refresh',
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
