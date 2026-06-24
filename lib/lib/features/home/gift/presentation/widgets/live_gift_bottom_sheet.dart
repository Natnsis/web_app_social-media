import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/widgets/in_app_webview_page.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_bloc.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_event.dart';
import 'package:faithconnect/features/home/gift/presentation/bloc/gift_state.dart';
import 'package:faithconnect/features/home/gift/presentation/widgets/gift_catalog_grid.dart';
import 'package:faithconnect/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Gift picker for live streams (TikTok-style send flow).
class LiveGiftBottomSheet extends StatefulWidget {
  final String streamId;
  final String hostName;

  const LiveGiftBottomSheet({
    super.key,
    required this.streamId,
    required this.hostName,
  });

  static Future<void> show(
    BuildContext context, {
    required String streamId,
    required String hostName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<GiftBloc>()..add(const GiftHubRequested()),
        child: LiveGiftBottomSheet(streamId: streamId, hostName: hostName),
      ),
    );
  }

  @override
  State<LiveGiftBottomSheet> createState() => _LiveGiftBottomSheetState();
}

class _LiveGiftBottomSheetState extends State<LiveGiftBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burstController;
  GiftItem? _pendingGift;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  void _playGiftBurst(String iconUrl) {
    _burstController.forward(from: 0);
    showSuccess(context, 'Sent gift');
  }

  Future<void> _openGiftPreview(GiftItem item) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _GiftSendPreviewSheet(item: item, hostName: widget.hostName);
      },
    );

    if (confirmed != true || !mounted) return;
    _pendingGift = item;
    context.read<GiftBloc>().add(
      SendGiftRequested(
        giftCatalogId: item.id,
        recipientChurchId: widget.streamId, // Assuming streamId maps to churchId
        quantity: 1,
        message: 'Gift to ${widget.hostName}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<GiftBloc, GiftState>(
      listener: (context, state) async {
        if (state is GiftLoaded) {
          if (state.feedbackMessage != null) {
            if (state.feedbackIsError) {
              showWarning(context, state.feedbackMessage!);
            } else {
              if (state.feedbackMessage?.toUpperCase() == 'SUCCESS') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Payment Successful'),
                    content: const Text('Your gift has been successfully processed!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
              final iconUrl = _pendingGift?.iconUrl ?? '';
              _playGiftBurst(iconUrl);
            }
            context.read<GiftBloc>().add(const GiftFeedbackDismissed());
          }
          if (state.checkoutUrl != null) {
            final url = state.checkoutUrl!;
            final txRef = state.txRef;
            context.read<GiftBloc>().add(const GiftFeedbackDismissed());
            
            await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => InAppWebViewPage(
                  url: url,
                  title: 'Complete Gift Payment',
                  returnUrl: 'google.com',
                ),
              ),
            );

            if (txRef != null && mounted) {
              context.read<GiftBloc>().add(GiftTransactionStatusChecked(txRef));
            }
          }
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: context.isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : colors.divider,
                    ),
                  ),
                  boxShadow: context.isDarkMode
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: colors.divider,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Send a gift to ${widget.hostName}',
                                style: GoogleFonts.inter(
                                  color: colors.primaryText,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: colors.iconMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        _GiftSheetBody(
                          state: state,
                          onGiftSelected: (item) {
                            _openGiftPreview(item);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: _GiftBurstOverlay(
                  controller: _burstController,
                  iconUrl: _pendingGift?.iconUrl ?? '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GiftSendPreviewSheet extends StatelessWidget {
  final GiftItem item;
  final String hostName;

  const _GiftSendPreviewSheet({required this.item, required this.hostName});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final panelColor = isDark ? const Color(0xFF11243A) : colors.cardBackground;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : colors.divider;
    final infoChipColor = isDark
        ? colors.brandBlue.withValues(alpha: 0.28)
        : colors.brandBlue.withValues(alpha: 0.14);
    final previewSurface = isDark
        ? colors.brandBlue.withValues(alpha: 0.18)
        : colors.tagBackground;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Send a Gift',
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
                  color: infoChipColor,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '$hostName receives ${item.name}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: previewSurface,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  children: [
                    Image.network(
                      item.iconUrl,
                      width: 56.sp,
                      height: 56.sp,
                      errorBuilder: (_, __, ___) =>
                          Icon(Iconsax.gift, size: 56.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Special gift for live support.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: colors.mutedText,
                        fontSize: 14.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: previewSurface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.star_1,
                      color: const Color(0xFFFFC84A),
                      size: 18.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${item.priceEtb.toInt()}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFC84A),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Pay with Stars',
                      style: GoogleFonts.inter(
                        color: colors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              PrimaryButton.feedAction(
                text: 'Send Gift',
                onPressed: () => Navigator.of(context).pop(true),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftSheetBody extends StatelessWidget {
  final GiftState state;
  final ValueChanged<GiftItem> onGiftSelected;

  const _GiftSheetBody({required this.state, required this.onGiftSelected});

  @override
  Widget build(BuildContext context) {
    if (state is GiftLoading || state is GiftInitial) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48.h),
        child: Center(
          child: CircularProgressIndicator(
            color: context.faithColors.brandBlue,
          ),
        ),
      );
    }

    if (state case GiftFailure(:final message)) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.faithColors.mutedText),
            ),
            AppSpacing.v16,
            PrimaryButton.feedAction(
              text: 'Retry',
              onPressed: () =>
                  context.read<GiftBloc>().add(const GiftHubRequested()),
            ),
          ],
        ),
      );
    }

    if (state case GiftLoaded(:final content, :final isSendingGift)) {
      return GiftCatalogGrid(
        catalog: content.catalog,
        isSending: isSendingGift,
        enableStaggerAnimation: true,
        onGiftSelected: onGiftSelected,
      );
    }

    return const SizedBox.shrink();
  }
}

class _GiftBurstOverlay extends StatelessWidget {
  final AnimationController controller;
  final String iconUrl;

  const _GiftBurstOverlay({required this.controller, required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(controller.value);
        if (t <= 0.001) return const SizedBox.shrink();

        return Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 52.h),
              child: SizedBox(
                width: 220.w,
                height: 220.h,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _BurstEmoji(
                      iconUrl: iconUrl,
                      progress: t,
                      dx: -70.w,
                      delay: 0.0,
                    ),
                    _BurstEmoji(
                      iconUrl: iconUrl,
                      progress: t,
                      dx: -35.w,
                      delay: 0.1,
                    ),
                    _BurstEmoji(
                      iconUrl: iconUrl,
                      progress: t,
                      dx: 0,
                      delay: 0.18,
                    ),
                    _BurstEmoji(
                      iconUrl: iconUrl,
                      progress: t,
                      dx: 35.w,
                      delay: 0.26,
                    ),
                    _BurstEmoji(
                      iconUrl: iconUrl,
                      progress: t,
                      dx: 70.w,
                      delay: 0.34,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BurstEmoji extends StatelessWidget {
  final String iconUrl;
  final double progress;
  final double dx;
  final double delay;

  const _BurstEmoji({
    required this.iconUrl,
    required this.progress,
    required this.dx,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
    if (local <= 0) return const SizedBox.shrink();

    final y = 140.h * local;
    final opacity = (1.0 - local).clamp(0.0, 1.0);
    final scale = 0.75 + (0.35 * local);

    return Transform.translate(
      offset: Offset(dx * local, -y),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Image.network(
            iconUrl,
            width: 26.sp,
            height: 26.sp,
            errorBuilder: (_, __, ___) => Icon(Iconsax.gift, size: 26.sp),
          ),
        ),
      ),
    );
  }
}
