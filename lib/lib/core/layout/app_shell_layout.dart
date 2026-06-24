import 'package:faithconnect/core/constants/app_bottom_nav_items.dart';

import 'package:faithconnect/core/layout/shell_tab_scope.dart';

import 'package:faithconnect/core/widgets/bottom_nav.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';



/// Application shell that hosts tab content and a shared [BottomNav].

///

/// Use with [StatefulShellRoute] so each branch renders inside [body]

/// while navigation state stays in the shell.

class AppShellLayout extends StatefulWidget {

  final StatefulNavigationShell navigationShell;

  final List<BottomNavItem> items;

  final BottomNavStyle? bottomNavStyle;

  final Widget? floatingActionButton;

  final FloatingActionButtonLocation? floatingActionButtonLocation;



  const AppShellLayout({

    super.key,

    required this.navigationShell,

    this.items = AppBottomNavItems.main,

    this.bottomNavStyle,

    this.floatingActionButton,

    this.floatingActionButtonLocation,

  });



  @override

  State<AppShellLayout> createState() => _AppShellLayoutState();

}



class _AppShellLayoutState extends State<AppShellLayout> {

  late final ValueNotifier<int> _tabIndex;



  @override

  void initState() {

    super.initState();

    _tabIndex = ValueNotifier(widget.navigationShell.currentIndex);

  }



  @override

  void didUpdateWidget(covariant AppShellLayout oldWidget) {

    super.didUpdateWidget(oldWidget);

    _syncTabIndex();

  }



  @override

  void dispose() {

    _tabIndex.dispose();

    super.dispose();

  }



  void _syncTabIndex() {

    final index = widget.navigationShell.currentIndex;

    if (_tabIndex.value != index) {

      _tabIndex.value = index;

    }

  }



  void _onItemSelected(int index) {

    widget.navigationShell.goBranch(

      index,

      initialLocation: index == widget.navigationShell.currentIndex,

    );

    _syncTabIndex();

  }



  @override

  Widget build(BuildContext context) {

    _syncTabIndex();



    return Scaffold(

      body: ShellTabScope(

        shell: widget.navigationShell,

        tabIndexListenable: _tabIndex,

        child: widget.navigationShell,

      ),

      floatingActionButton: widget.floatingActionButton,

      floatingActionButtonLocation: widget.floatingActionButtonLocation,

      bottomNavigationBar: BottomNav(

        items: widget.items,

        selectedIndex: widget.navigationShell.currentIndex,

        onItemSelected: _onItemSelected,

        style: widget.bottomNavStyle,

      ),

    );

  }

}

