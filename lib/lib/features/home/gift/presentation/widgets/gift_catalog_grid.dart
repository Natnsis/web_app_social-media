import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_catalog.dart';
import 'package:faithconnect/features/home/gift/domain/entities/gift_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class GiftCatalogGrid extends StatelessWidget {
  final GiftCatalog catalog;
  final bool isSending;
  final ValueChanged<GiftItem> onGiftSelected;
  final bool enableStaggerAnimation;

  const GiftCatalogGrid({
    super.key,
    required this.catalog,
    required this.onGiftSelected,
    this.isSending = false,
    this.enableStaggerAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: catalog.items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final item = catalog.items[index];
            final canAfford = catalog.balanceEtb >= item.priceEtb;

            return _GiftTile(
              index: index,
              item: item,
              canAfford: canAfford,
              isSending: isSending,
              animateIn: enableStaggerAnimation,
              onTap: canAfford && !isSending
                  ? () => onGiftSelected(item)
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _GiftTile extends StatefulWidget {
  final int index;
  final GiftItem item;
  final bool canAfford;
  final bool isSending;
  final bool animateIn;
  final VoidCallback? onTap;

  const _GiftTile({
    required this.index,
    required this.item,
    required this.canAfford,
    required this.isSending,
    required this.animateIn,
    this.onTap,
  });

  @override
  State<_GiftTile> createState() => _GiftTileState();
}

class _GiftTileState extends State<_GiftTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _badgePulse;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1600 + (widget.index % 4) * 140),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -3.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _badgePulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final opacity = widget.canAfford ? 1.0 : 0.45;
    final tileFill = isDark ? const Color(0xFF13253A) : colors.cardBackground;
    final tileBorder = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : colors.divider;
    final badgeFill = isDark ? const Color(0xFF223747) : colors.tagBackground;
    final labelColor = isDark ? Colors.white : colors.primaryText;

    final tile = Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: tileFill,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: tileBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
                blurRadius: isDark ? 12 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 120;
                  final emojiSize = compact ? 32.sp : 38.sp;
                  final labelSize = compact ? 10.sp : 11.sp;
                  final costSize = compact ? 11.sp : 12.sp;
                  final starSize = compact ? 16.r : 18.r;
                  final sparkleSize = compact ? 9.r : 11.r;
                  final dropletLarge = compact ? 5.r : 6.5.r;
                  final dropletMid = compact ? 4.r : 5.r;
                  final dropletSmall = compact ? 3.5.r : 4.5.r;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          );
                        },
                        child: Image.network(
                          widget.item.iconUrl,
                          width: emojiSize,
                          height: emojiSize,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Iconsax.gift, size: emojiSize);
                          },
                        ),
                      ),
                      SizedBox(height: compact ? 4.h : 6.h),
                      Flexible(
                        child: Text(
                          widget.item.name,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: labelColor,
                            fontSize: labelSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      AnimatedBuilder(
                        animation: _badgePulse,
                        builder: (context, _) {
                          final glow = _badgePulse.value;
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 8.w : 10.w,
                              vertical: compact ? 4.h : 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: badgeFill,
                              borderRadius: BorderRadius.circular(999.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFC84A,
                                  ).withValues(alpha: 0.08 + (0.12 * glow)),
                                  blurRadius: 4 + (6 * glow),
                                  spreadRadius: 0.4 + (0.8 * glow),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Iconsax.star_1,
                                        size: starSize,
                                        color: const Color(0xFFFFC84A),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${widget.item.priceEtb.toInt()}',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFFFD166),
                                          fontSize: costSize,
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'ETB',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFFFFD166),
                                          fontSize: costSize * 0.8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: -2.w,
                                  top: -2.h,
                                  child: Opacity(
                                    opacity: (0.25 + 0.75 * glow)
                                        .clamp(0.0, 1.0)
                                        .toDouble(),
                                    child: Icon(
                                      Iconsax.star_1,
                                      size: sparkleSize,
                                      color: const Color(0xFFFFE38C),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -3.w,
                                  top: 1.h - (3.h * glow),
                                  child: Opacity(
                                    opacity: (0.18 + 0.52 * (1 - glow))
                                        .clamp(0.0, 1.0)
                                        .toDouble(),
                                    child: Container(
                                      width: dropletLarge,
                                      height: dropletLarge,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFE8A3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 6.w + (2.w * glow),
                                  bottom: -2.h,
                                  child: Opacity(
                                    opacity: (0.16 + 0.55 * glow)
                                        .clamp(0.0, 1.0)
                                        .toDouble(),
                                    child: Container(
                                      width: dropletMid,
                                      height: dropletMid,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFD56E),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12.w,
                                  top: -1.h + (2.h * glow),
                                  child: Opacity(
                                    opacity: (0.14 + 0.5 * (1 - glow))
                                        .clamp(0.0, 1.0)
                                        .toDouble(),
                                    child: Container(
                                      width: dropletSmall,
                                      height: dropletSmall,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFC84A),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.animateIn) return tile;

    final start = (widget.index * 0.07).clamp(0, 0.78).toDouble();
    final opacityCurve = Interval(start, 1, curve: Curves.easeOutCubic);
    final popCurve = Interval(start, 1, curve: Curves.easeOutBack);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final rawOpacity = opacityCurve.transform(value);
        final safeOpacity = rawOpacity.isFinite
            ? rawOpacity.clamp(0.0, 1.0).toDouble()
            : 1.0;
        final popValue = popCurve.transform(value);
        final safePop = popValue.isFinite ? popValue : 1.0;
        return Opacity(
          opacity: safeOpacity,
          child: Transform.translate(
            offset: Offset(0, (1 - safePop) * 18.h),
            child: Transform.scale(
              scale: 0.92 + (0.08 * safePop),
              child: child,
            ),
          ),
        );
      },
      child: tile,
    );
  }
}
