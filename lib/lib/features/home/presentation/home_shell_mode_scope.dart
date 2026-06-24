import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';
import 'package:flutter/material.dart';

class HomeShellModeScope extends InheritedNotifier<HomeShellModeNotifier> {
  const HomeShellModeScope({
    super.key,
    required HomeShellModeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static HomeShellModeNotifier of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<HomeShellModeScope>();
    assert(scope != null, 'HomeShellModeScope not found');
    return scope!.notifier!;
  }

  static HomeShellModeNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HomeShellModeScope>()
        ?.notifier;
  }
}
