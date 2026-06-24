import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:faithconnect/core/core.dart';

enum AppSnackBarType { success, error, warning, info }

class AppSnackBar {
  static OverlayEntry? _activeTopOverlay;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required AppSnackBarType type,
    String? actionLabel,
    VoidCallback? onAction,
    bool isLoading = false,
    Duration duration = const Duration(seconds: 4),
    bool isPersistent = false,
    bool isTop = false,
  }) {
    if (isTop) {
      _showTopSnackBar(
        context,
        title: title,
        message: message,
        type: type,
        duration: duration,
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final colorScheme = Theme.of(context).colorScheme;
    final config = _getSnackBarConfig(colorScheme, type);

    messenger.showSnackBar(
      SnackBar(
        duration: isPersistent ? const Duration(days: 1) : duration,
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 16.h,
          left: 16.w,
          right: 16.w,
        ),
        padding: EdgeInsets.zero,
        content: _AppSnackBarContent(
          title: title,
          message: message,
          type: type,
          config: config,
          actionLabel: actionLabel,
          onAction: onAction,
          isLoading: isLoading,
          duration: duration,
          onClose: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static _SnackBarConfig _getSnackBarConfig(ColorScheme colorScheme, AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return _SnackBarConfig(
          icon: HugeIcons.strokeRoundedTick01,
          backgroundColor: colorScheme.success50,
          borderColor: colorScheme.success400,
          iconColor: colorScheme.success,
          progressColor: colorScheme.success,
        );
      case AppSnackBarType.error:
        return _SnackBarConfig(
          icon: HugeIcons.strokeRoundedAlertCircle,
          backgroundColor: colorScheme.error50,
          borderColor: colorScheme.error400,
          iconColor: colorScheme.error,
          progressColor: colorScheme.error,
        );
      case AppSnackBarType.warning:
        return _SnackBarConfig(
          icon: HugeIcons.strokeRoundedAlertCircle,
          backgroundColor: colorScheme.warning50,
          borderColor: colorScheme.warning400,
          iconColor: colorScheme.warning,
          progressColor: colorScheme.warning,
        );
      case AppSnackBarType.info:
        return _SnackBarConfig(
          icon: HugeIcons.strokeRoundedInformationCircle,
          backgroundColor: colorScheme.info50,
          borderColor: colorScheme.info400,
          iconColor: colorScheme.info,
          progressColor: colorScheme.info,
        );
    }
  }

  static void _showTopSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required AppSnackBarType type,
    required Duration duration,
  }) {
    if (_activeTopOverlay?.mounted == true) {
      // Discard concurrent messages while one is visible.
      return;
    }

    final OverlayState? overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    final config = _getSnackBarConfig(colorScheme, type);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackBarOverlay(
        title: title,
        message: message,
        config: config,
        type: type,
        duration: duration,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
          if (identical(_activeTopOverlay, overlayEntry)) {
            _activeTopOverlay = null;
          }
        },
      ),
    );

    _activeTopOverlay = overlayEntry;
    overlayState.insert(overlayEntry);
  }
}

class _SnackBarConfig {
  final dynamic icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color progressColor;

  const _SnackBarConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.progressColor,
  });
}

class _TopSnackBarOverlay extends StatefulWidget {
  final String title;
  final String message;
  final _SnackBarConfig config;
  final AppSnackBarType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopSnackBarOverlay({
    required this.title,
    required this.message,
    required this.config,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarOverlay> createState() => _TopSnackBarOverlayState();
}

class _TopSnackBarOverlayState extends State<_TopSnackBarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10.h,
      left: 16.w,
      right: 16.w,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: _AppSnackBarContent(
            title: widget.title,
            message: widget.message,
            type: widget.type,
            config: widget.config,
            isLoading: false,
            duration: widget.duration,
            onClose: () {
              if (mounted) {
                _controller.reverse().then((_) {
                  if (mounted) widget.onDismiss();
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

class _AppSnackBarContent extends StatefulWidget {
  final String title;
  final String message;
  final AppSnackBarType type;
  final _SnackBarConfig config;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final Duration duration;
  final VoidCallback onClose;

  const _AppSnackBarContent({
    required this.title,
    required this.message,
    required this.type,
    required this.config,
    this.actionLabel,
    this.onAction,
    required this.isLoading,
    required this.duration,
    required this.onClose,
  });

  @override
  State<_AppSnackBarContent> createState() => _AppSnackBarContentState();
}

class _AppSnackBarContentState extends State<_AppSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _progressController.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.config.backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: widget.config.borderColor, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 12.w, 16.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: widget.config.iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: widget.config.icon,
                        color: widget.config.iconColor,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: widget.config.iconColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.message,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: widget.config.iconColor.withValues(alpha: 0.8),
                            ),
                          ),
                          if (widget.actionLabel != null) ...[
                            SizedBox(height: 12.h),
                            InkWell(
                              onTap: widget.onAction,
                              child: Text(
                                widget.actionLabel!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: widget.config.progressColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 20.w,
                        color: widget.config.iconColor.withValues(alpha: 0.5),
                      ),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              if (!widget.isLoading)
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.config.progressColor,
                      ),
                      minHeight: 3.h,
                    );
                  },
                ),
            ],
          ),
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0),
              highlightColor: Colors.white.withValues(alpha: 0.3),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
