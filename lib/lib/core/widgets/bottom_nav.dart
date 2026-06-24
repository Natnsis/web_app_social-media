import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Descriptor for a single tab in [BottomNav].
///
/// Use [Iconsax] icons from `iconsax_flutter` (outline + `*_copy` for active).
class BottomNavItem {
  final String id;
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const BottomNavItem({
    required this.id,
    required this.icon,
    this.activeIcon,
    required this.label,
  });

  IconData iconFor(bool selected) => selected ? (activeIcon ?? icon) : icon;
}

/// Visual tokens for [BottomNav].
class BottomNavStyle {
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color activeCircleColor;
  final Color activeCircleBorderColor;
  final double barHeight;
  final double notchWidth;
  final double notchRise;
  final double bottomCornerRadius;
  final double topCornerRadius;
  final double horizontalMargin;

  const BottomNavStyle({
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.activeCircleColor,
    required this.activeCircleBorderColor,
    this.barHeight = 60,
    this.notchWidth = 72,
    this.notchRise = 22,
    this.bottomCornerRadius = 22,
    this.topCornerRadius = 0,
    this.horizontalMargin = 0,
  });

  /// FaithConnect wavy bar: navy background, center bump, blue active tab.
  static const BottomNavStyle dark = BottomNavStyle(
    backgroundColor: Color(0xFF111B26),
    selectedColor: Color(0xFF0096FF),
    unselectedColor: Colors.white,
    activeCircleColor: Color(0xFF0A1520),
    activeCircleBorderColor: Color(0xFF1C2D3F),
    barHeight: 60,
    notchWidth: 76,
    notchRise: 24,
    bottomCornerRadius: 24,
    topCornerRadius: 0,
    horizontalMargin: 0,
  );

  factory BottomNavStyle.fromContext(BuildContext context) {
    final colors = context.faithColors;

    if (context.isDarkMode) {
      return BottomNavStyle(
        backgroundColor: const Color(0xFF111B26),
        selectedColor: colors.brandBlue,
        unselectedColor: Colors.white,
        activeCircleColor: const Color(0xFF0A1520),
        activeCircleBorderColor: const Color(0xFF1C2D3F),
        barHeight: dark.barHeight,
        notchWidth: dark.notchWidth,
        notchRise: dark.notchRise,
        bottomCornerRadius: dark.bottomCornerRadius,
      );
    }

    return BottomNavStyle(
      backgroundColor: colors.navBarBackground,
      selectedColor: colors.brandBlue,
      unselectedColor: colors.mutedText,
      activeCircleColor: colors.tagBackground,
      activeCircleBorderColor: colors.divider,
      barHeight: dark.barHeight,
      notchWidth: dark.notchWidth,
      notchRise: dark.notchRise,
      bottomCornerRadius: dark.bottomCornerRadius,
    );
  }
}

/// Wavy bottom navigation with a raised center bump on the active tab.
class BottomNav extends StatefulWidget {
  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final BottomNavStyle? style;

  const BottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.style,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _indexAnimation;
  double _displayIndex = 0;

  @override
  void initState() {
    super.initState();
    _displayIndex = widget.selectedIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _indexAnimation = AlwaysStoppedAnimation(_displayIndex);
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _indexAnimation =
          Tween<double>(
            begin: _displayIndex,
            end: widget.selectedIndex.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOutCubicEmphasized,
            ),
          );
      _controller.forward(from: 0).whenComplete(() {
        if (mounted) {
          setState(() => _displayIndex = widget.selectedIndex.toDouble());
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _animatedIndex =>
      _controller.isAnimating ? _indexAnimation.value : _displayIndex;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? BottomNavStyle.fromContext(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barHeight = style.barHeight.h;
    final notchRise = style.notchRise.h;
    final totalHeight = barHeight + notchRise + bottomInset;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: context.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SizedBox(
      height: totalHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final centerFraction =
              (_animatedIndex + 0.5) / widget.items.length.clamp(1, 999);

          return Padding(
            padding: EdgeInsets.only(
              left: style.horizontalMargin.w,
              right: style.horizontalMargin.w,
              bottom: bottomInset,
            ),
            child: SizedBox(
              height: barHeight + notchRise,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  final notchCenterX = barWidth * centerFraction;

                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _BottomNavShapePainter(
                            style: style,
                            notchCenterX: notchCenterX,
                            notchRise: notchRise,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(widget.items.length, (i) {
                            final distance =
                                (i - _animatedIndex).abs().clamp(0.0, 1.0);
                            final selectionT = 1 - distance;

                            return Expanded(
                              child: _BottomNavItemTile(
                                item: widget.items[i],
                                isSelected: i == widget.selectedIndex,
                                selectionT: selectionT,
                                style: style,
                                onTap: () => widget.onItemSelected(i),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}

/// Paints full-width bar: rounded bottom corners + upward bump at [notchCenterX].
class _BottomNavShapePainter extends CustomPainter {
  final BottomNavStyle style;
  final double notchCenterX;
  final double notchRise;

  _BottomNavShapePainter({
    required this.style,
    required this.notchCenterX,
    required this.notchRise,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final fill = Paint()
      ..color = style.backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fill);
  }

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    final topY = notchRise;
    final cx = notchCenterX.clamp(
      style.notchWidth / 2 + 8,
      w - style.notchWidth / 2 - 8,
    );
    final halfW = style.notchWidth / 2;
    final peakY = 0.0;
    final bottomR = style.bottomCornerRadius;
    final shoulder = halfW * 0.42;
    final lift = notchRise * 0.08;

    final path = Path();

    path.moveTo(bottomR, h);
    path.arcToPoint(
      Offset(0, h - bottomR),
      radius: Radius.circular(bottomR),
      clockwise: false,
    );
    path.lineTo(0, topY);

    final leftNotch = cx - halfW;
    if (leftNotch > 0) {
      path.lineTo(leftNotch, topY);
    }

    path.cubicTo(
      cx - halfW + shoulder,
      topY,
      cx - halfW * 0.55,
      topY - lift,
      cx,
      peakY,
    );
    path.cubicTo(
      cx + halfW * 0.55,
      topY - lift,
      cx + halfW - shoulder,
      topY,
      cx + halfW,
      topY,
    );

    final rightNotch = cx + halfW;
    if (rightNotch < w) {
      path.lineTo(w, topY);
    }

    path.lineTo(w, h - bottomR);
    path.arcToPoint(
      Offset(w - bottomR, h),
      radius: Radius.circular(bottomR),
      clockwise: false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _BottomNavShapePainter oldDelegate) {
    return oldDelegate.notchCenterX != notchCenterX ||
        oldDelegate.notchRise != notchRise ||
        oldDelegate.style != style;
  }
}

class _BottomNavItemTile extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final double selectionT;
  final BottomNavStyle style;
  final VoidCallback onTap;

  const _BottomNavItemTile({
    required this.item,
    required this.isSelected,
    required this.selectionT,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = Color.lerp(
      style.unselectedColor,
      style.selectedColor,
      selectionT,
    )!;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, -10.h * selectionT),
                  child: _NavIcon(
                    icon: item.iconFor(selectionT > 0.5),
                    selectionT: selectionT,
                    style: style,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: labelColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.lerp(
                      FontWeight.w400,
                      FontWeight.w600,
                      selectionT,
                    ),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final double selectionT;
  final BottomNavStyle style;

  const _NavIcon({
    required this.icon,
    required this.selectionT,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final slot = 44.r;
    final iconSize = (24 + (22 - 24) * selectionT).r;
    final iconColor = Color.lerp(
      style.unselectedColor,
      style.selectedColor,
      selectionT,
    )!;
    final showCircle = selectionT > 0.5;

    return SizedBox(
      width: slot,
      height: slot,
      child: Center(
        child: showCircle
            ? Container(
                width: slot,
                height: slot,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: style.activeCircleColor,
                  border: Border.all(
                    color: style.activeCircleBorderColor,
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: iconSize, color: iconColor),
              )
            : Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
