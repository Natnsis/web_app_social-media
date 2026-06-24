import 'package:faithconnect/core/constants/app_bottom_nav_items.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';



/// Exposes [StatefulNavigationShell] tab index so branch pages can pause

/// video/audio when another tab is selected.

///

/// Uses a stable [tabIndexListenable] (owned by [AppShellLayout]) instead of

/// [InheritedWidget] rebuild subscriptions to avoid `_dependents.isEmpty`

/// assertions when [StatefulShellRoute] rebuilds the shell.

class ShellTabScope extends InheritedWidget {

  final StatefulNavigationShell shell;

  final ValueListenable<int> tabIndexListenable;



  const ShellTabScope({

    super.key,

    required this.shell,

    required this.tabIndexListenable,

    required super.child,

  });



  /// Read-only lookup; does not subscribe to tab changes.

  static ShellTabScope? of(BuildContext context) {

    final element =

        context.getElementForInheritedWidgetOfExactType<ShellTabScope>();

    return element?.widget as ShellTabScope?;

  }



  bool isTabActive(String tabId) {

    final index = AppBottomNavItems.indexOf(tabId);

    if (index < 0) return false;

    return shell.currentIndex == index;

  }



  @override

  bool updateShouldNotify(ShellTabScope oldWidget) => false;

}

