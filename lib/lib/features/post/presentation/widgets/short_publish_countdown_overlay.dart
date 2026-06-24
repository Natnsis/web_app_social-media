import 'dart:async';

import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen overlay shown after a short is uploaded while the video
/// finishes processing. Counts down [duration] then calls [onComplete].
class ShortPublishCountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const ShortPublishCountdownOverlay({
    super.key,
    required this.onComplete,
    this.duration = const Duration(seconds: 60),
  });

  @override
  State<ShortPublishCountdownOverlay> createState() =>
      _ShortPublishCountdownOverlayState();
}

class _ShortPublishCountdownOverlayState
    extends State<ShortPublishCountdownOverlay> {
  static const _tick = Duration(seconds: 1);

  late final int _totalSeconds;
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.duration.inSeconds;
    _secondsRemaining = _totalSeconds;
    _timer = Timer.periodic(_tick, _onTick);
  }

  void _onTick(Timer timer) {
    if (!mounted) return;

    if (_secondsRemaining <= 1) {
      timer.cancel();
      setState(() => _secondsRemaining = 0);
      widget.onComplete();
      return;
    }

    setState(() => _secondsRemaining -= 1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _progress {
    if (_totalSeconds <= 0) return 1;
    return (1 - (_secondsRemaining / _totalSeconds)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Material(
      color: colors.scaffoldBackground.withValues(alpha: 0.96),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120.r,
                  height: 120.r,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 5.r,
                        backgroundColor: colors.tagBackground,
                        color: colors.brandBlue,
                      ),
                      Text(
                        '$_secondsRemaining',
                        style: GoogleFonts.inter(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  'Publishing your short',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.headerTitle,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Your video will be ready in about $_secondsRemaining '
                  '${_secondsRemaining == 1 ? 'second' : 'seconds'}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: colors.mutedText,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 24.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 4.h,
                    backgroundColor: colors.tagBackground,
                    color: colors.brandBlue,
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
