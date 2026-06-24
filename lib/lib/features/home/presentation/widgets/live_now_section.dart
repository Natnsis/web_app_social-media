import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/domain/entities/live_now_item.dart';
import 'package:faithconnect/features/live_streaming/presentation/navigation/live_stream_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveNowSection extends StatelessWidget {
  final List<LiveNowItem> items;

  const LiveNowSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.faithColors;
    final liveItems = items
        .where((item) => item.isLive)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                // Gradient-decorated "Live Now" title
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [colors.brandSky, colors.brandBlue],
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'Live Now',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: Builder(
                  builder: (context) {
                    return InkWell(
                      onTap: () => LiveStreamNavigation.openHub(context),
                      borderRadius: BorderRadius.circular(999.r),
                      child: Ink(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tagBackground,
                          borderRadius: BorderRadius.circular(999.r),
                          border: context.isDarkMode
                              ? null
                              : Border.all(color: colors.divider),
                        ),
                        child: Text(
                          'VIEW ALL',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.isDarkMode
                                ? colors.mutedText
                                : colors.brandBlue,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: child,
              ),
            );
          },
          child: liveItems.isEmpty
              ? Padding(
                  key: const ValueKey('no_live_card'),
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _NoLiveNowCard(
                    canStartLive: context.readRoleAccess().showCreateActions,
                  ),
                )
              : SizedBox(
                  key: const ValueKey('live_list'),
                  height: 108.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: liveItems.length,
                    separatorBuilder: (context, index) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) {
                      return _LiveAvatar(item: liveItems[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _NoLiveNowCard extends StatelessWidget {
  final bool canStartLive;

  const _NoLiveNowCard({required this.canStartLive});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AppCompactCard(
        borderRadius: 16,
        child: Row(
          children: [
            Icon(Icons.live_tv_outlined, color: colors.mutedText, size: 20.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                canStartLive
                    ? 'No live streams right now'
                    : 'No live streams right now. Check back to join when someone goes live.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.mutedText),
              ),
            ),
            if (canStartLive) ...[
              SizedBox(width: 8.w),
              SizedBox(
                width: 96.w,
                child: PrimaryButton.feedAction(
                  text: 'Go Live',
                  onPressed: () => LiveStreamNavigation.openGoLive(context),
                ),
              ),
            ] else ...[
              SizedBox(width: 8.w),
              SizedBox(
                width: 96.w,
                child: PrimaryButton.feedAction(
                  text: 'View All',
                  onPressed: () => LiveStreamNavigation.openHub(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LiveAvatar extends StatefulWidget {
  final LiveNowItem item;

  const _LiveAvatar({required this.item});

  @override
  State<_LiveAvatar> createState() => _LiveAvatarState();
}

class _LiveAvatarState extends State<_LiveAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context) {
    LiveStreamNavigation.openFromLiveNowItem(
      context,
      isLive: widget.item.isLive,
      streamId: widget.item.streamId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.faithColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _onTap(context),
        child: SizedBox(
          width: 72.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 72.r,
                height: 72.r,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final pulse = _animationController.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Pulsing outer halo ring
                        Container(
                          width: (64 + (12 * pulse)).r,
                          height: (64 + (12 * pulse)).r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.brandBlue.withValues(
                                alpha: 0.6 * (1.0 - pulse),
                              ),
                              width: (1.5 + (1.5 * pulse)).r,
                            ),
                          ),
                        ),
                        // Inner gradient active ring
                        Container(
                          width: 68.r,
                          height: 68.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(0xFF7883D1),
                                Color(0xFFFDBA9B),
                                Color(0xFFFDBA9B),
                              ],
                              stops: [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                        // Profile Avatar
                        Container(
                          width: 62.r,
                          height: 62.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.cardBackground,
                            border: Border.all(
                              color: colors.cardBackground,
                              width: 3,
                            ),
                            image: widget.item.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.item.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: widget.item.avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  color: colors.mutedText,
                                  size: 28.r,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: -6.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDBA9B),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: colors.cardBackground,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'LIVE',
                              style: TextStyle(
                                color: const Color(0xFF5A0000),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                widget.item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
