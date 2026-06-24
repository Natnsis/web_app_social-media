import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Red-dot LIVE pill for streams and previews.
class LiveIndicatorBadge extends StatefulWidget {
  final bool compact;
  final bool pulse;

  const LiveIndicatorBadge({
    super.key,
    this.compact = false,
    this.pulse = false,
  });

  @override
  State<LiveIndicatorBadge> createState() => _LiveIndicatorBadgeState();
}

class _LiveIndicatorBadgeState extends State<LiveIndicatorBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.pulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveIndicatorBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.pulse) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 10.w : 12.w,
        vertical: widget.compact ? 5.h : 7.h,
      ),
      // decoration: BoxDecoration(
      //   color: DarkTheme.redDanger500.withValues(alpha: 0.22),
      //   borderRadius: BorderRadius.circular(20.r),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: widget.pulse ? _pulse : const AlwaysStoppedAnimation(1.0),
            child: Container(
              width: widget.compact ? 6.r : 8.r,
              height: widget.compact ? 6.r : 8.r,
              decoration: const BoxDecoration(
                color: DarkTheme.redDanger500,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'LIVE',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: widget.compact ? 11.sp : 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
