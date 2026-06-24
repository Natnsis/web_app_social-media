import 'package:faithconnect/core/constants/app_bottom_nav_items.dart';
import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers for the Shorts tab.
abstract final class ShortsNavigation {
  ShortsNavigation._();

  static bool _pendingFeedRefresh = false;

  /// Returns `true` once when the shorts feed should reload after publish.
  static bool takePendingFeedRefresh() {
    if (!_pendingFeedRefresh) return false;
    _pendingFeedRefresh = false;
    return true;
  }

  /// Closes the compose screen and opens Shorts with a feed refresh.
  static void openAfterPublish(BuildContext context) {
    _pendingFeedRefresh = true;

    if (context.canPop()) {
      context.pop();
    }

    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      final shortsIndex = AppBottomNavItems.indexOf('shorts');
      shell.goBranch(
        shortsIndex,
        initialLocation: shell.currentIndex == shortsIndex,
      );
      return;
    }

    context.go(RoutesConstant.shorts);
  }
}
