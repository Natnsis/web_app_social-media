import 'package:flutter/material.dart';
import 'package:faithconnect/core/core.dart';

class LoadingDialog {
  static bool _isShowing = false;
  static bool get isShowing => _isShowing;

  static void show(
    BuildContext context, {
    String? message,
    bool dismissible = false,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: dismissible,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogContext) {
        return PopScope(
          canPop: dismissible,
          child: Center(
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(minWidth: 140),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(dialogContext).colorScheme.primary500,
                        ),
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) => _isShowing = false);
  }

  static void showLoading(
    BuildContext context, {
    String? message,
    bool dismissible = false,
  }) {
    show(context, message: message, dismissible: dismissible);
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static void hideAll(BuildContext context) {
    _isShowing = false;
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);
  }
}
