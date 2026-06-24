import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_bloc.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_event.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_state.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_catalog.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';
import 'package:faithconnect/features/home/gift/presentation/widgets/gift_app_bar.dart';
import 'package:faithconnect/features/home/gift/presentation/widgets/gift_catalog_grid.dart';
import 'package:faithconnect/features/home/gift/presentation/widgets/gift_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class GiftPage extends StatefulWidget {
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage> {
  @override
  void initState() {
    super.initState();
    context.read<GiftBloc>().add(const GiftHubRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return BlocBuilder<GiftBloc, GiftState>(
      builder: (context, state) {
        final title = switch (state) {
          GiftLoaded(:final content) => content.title,
          _ => 'Gift',
        };

        return AppBarPageScaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: GiftAppBar(title: title),
          body: _GiftBody(state: state),
        );
      },
    );
  }
}

class _GiftBody extends StatelessWidget {
  final GiftState state;

  const _GiftBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is GiftLoading || state is GiftInitial) {
      return const _GiftBodyPlaceholder();
    }

    if (state case GiftFailure(:final message)) {
      return _GiftFailureView(message: message);
    }

    if (state case GiftLoaded(:final content, :final isSendingGift)) {
      return _GiftLoadedView(
        catalog: content.catalog,
        isSendingGift: isSendingGift,
      );
    }

    return const SizedBox.shrink();
  }
}

class _GiftLoadedView extends StatefulWidget {
  final GiftCatalog catalog;
  final bool isSendingGift;

  const _GiftLoadedView({
    required this.catalog,
    required this.isSendingGift,
  });

  @override
  State<_GiftLoadedView> createState() => _GiftLoadedViewState();
}

class _GiftLoadedViewState extends State<_GiftLoadedView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onGiftTap(GiftItem item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GiftHubActionSheet(item: item),
    );
    if (action == null || !mounted) return;
    if (action == 'live') {
      context.pushNamed(RoutesConstant.liveStreams);
    } else if (action == 'church') {
      context.pushNamed(RoutesConstant.giftChurchSearch, extra: item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        const _GiftIntroCard(),
        SizedBox(height: 14.h),
        _GiftLiveHintCard(
          onBrowseLive: () => context.pushNamed(RoutesConstant.liveStreams),
        ),
        SizedBox(height: 22.h),
        FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: GiftCatalogGrid(
              catalog: widget.catalog,
              isSending: widget.isSendingGift,
              enableStaggerAnimation: true,
              onGiftSelected: _onGiftTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _GiftHubActionSheet extends StatelessWidget {
  final GiftItem item;

  const _GiftHubActionSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final panelColor = isDark ? const Color(0xFF102137) : colors.cardBackground;
    final panelBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : colors.divider;
    final chipColor = isDark
        ? colors.brandBlue.withValues(alpha: 0.26)
        : colors.brandBlue.withValues(alpha: 0.12);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: panelBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Gift selected',
                    style: GoogleFonts.inter(
                      color: colors.primaryText,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(Icons.close_rounded, color: colors.iconMuted),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'You chose ${item.name}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Where would you like to send this gift?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: colors.secondaryText,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 14.h),
              PrimaryButton.feedAction(
                text: 'Send to a Church',
                onPressed: () => Navigator.of(context).pop('church'),
                width: double.infinity,
                icon: const Icon(Icons.church_outlined, color: Colors.white, size: 20),
              ),
              SizedBox(height: 8.h),
              PrimaryButton.outlinedAction(
                text: 'Open live streams',
                onPressed: () => Navigator.of(context).pop('live'),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftIntroCard extends StatelessWidget {
  const _GiftIntroCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return GiftSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: colors.brandBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.gift,
              color: colors.brandBlue,
              size: 30.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support with gifts',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Send faith-themed gifts during live streams to encourage hosts and ministries.',
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 13.sp,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftLiveHintCard extends StatelessWidget {
  final VoidCallback onBrowseLive;

  const _GiftLiveHintCard({required this.onBrowseLive});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;

    return GiftSurfaceCard(
      backgroundColor: isDark
          ? colors.brandBlue.withValues(alpha: 0.12)
          : colors.brandBlue.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.video_play,
                color: colors.brandBlue,
                size: 22.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Gifts are sent during live streams',
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Browse live sessions, tap the gift button on a stream, and pick a gift from your coin balance.',
            style: GoogleFonts.inter(
              color: colors.mutedText,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
          PrimaryButton.feedAction(
            text: 'Browse live streams',
            onPressed: onBrowseLive,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _GiftFailureView extends StatelessWidget {
  final String message;

  const _GiftFailureView({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: GiftSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.warning_2,
                color: colors.brandBlue,
                size: 40.r,
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
              AppSpacing.v16,
              PrimaryButton.feedAction(
                text: 'Retry',
                onPressed: () =>
                    context.read<GiftBloc>().add(const GiftHubRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftBodyPlaceholder extends StatelessWidget {
  const _GiftBodyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return FaithShimmer(
      child: ColoredBox(
        color: faithShimmerScreenFill(context),
        child: const SizedBox.expand(),
      ),
    );
  }
}
