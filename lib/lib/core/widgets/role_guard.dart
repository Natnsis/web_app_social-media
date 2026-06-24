import 'package:faithconnect/core/access/role_guard_access.dart';
import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:faithconnect/core/widgets/app_message.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_scope.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:faithconnect/core/access/role_guard_access.dart';

/// How [RoleGuard] responds when the requirement is not met.
enum RoleGuardBehavior {
  /// Pops or navigates home and shows a message.
  redirect,

  /// Renders [fallback] or an empty box — child is not built.
  hide,
}

/// Blocks or hides content when the signed-in user lacks the required role.
///
/// Wrap routes (create flows) with [redirect], or gate widgets with [hide]:
/// ```dart
/// RoleGuard(
///   requirement: AppRoleRequirement.elevated,
///   behavior: RoleGuardBehavior.hide,
///   child: CreatePostFab(...),
/// )
/// ```
class RoleGuard extends StatelessWidget {
  final AppRoleRequirement requirement;
  final RoleGuardBehavior behavior;
  final Widget child;
  final Widget? fallback;
  final String? deniedMessage;
  final String? redirectRoute;

  const RoleGuard({
    super.key,
    required this.requirement,
    required this.child,
    this.behavior = RoleGuardBehavior.redirect,
    this.fallback,
    this.deniedMessage,
    this.redirectRoute,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuardBuilder(
      builder: (context, access) {
        if (access.meets(requirement)) return child;

        return switch (behavior) {
          RoleGuardBehavior.redirect => _RoleGuardDenied(
              deniedMessage: deniedMessage,
              redirectRoute: redirectRoute,
            ),
          RoleGuardBehavior.hide => fallback ?? const SizedBox.shrink(),
        };
      },
    );
  }
}

/// Listens to [HomeShellModeNotifier] and exposes [RoleGuardAccess] to descendants.
///
/// Use on pages that adapt UI by role (e.g. account profile FAB, church tabs).
class RoleGuardBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, RoleGuardAccess access) builder;

  const RoleGuardBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final shellMode = HomeShellModeScope.maybeOf(context);
    if (shellMode == null) {
      return builder(context, const RoleGuardAccess.guest());
    }

    return ListenableBuilder(
      listenable: shellMode,
      builder: (context, _) =>
          builder(context, RoleGuardAccess.from(shellMode)),
    );
  }
}

extension RoleGuardContext on BuildContext {
  RoleGuardAccess readRoleAccess() {
    final shellMode = HomeShellModeScope.maybeOf(this);
    if (shellMode == null) return const RoleGuardAccess.guest();
    return RoleGuardAccess.from(shellMode);
  }
}

class _RoleGuardDenied extends StatefulWidget {
  final String? deniedMessage;
  final String? redirectRoute;

  const _RoleGuardDenied({
    this.deniedMessage,
    this.redirectRoute,
  });

  @override
  State<_RoleGuardDenied> createState() => _RoleGuardDeniedState();
}

class _RoleGuardDeniedState extends State<_RoleGuardDenied> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showInfo(
        context,
        widget.deniedMessage ??
            'This action is only available for church administrator accounts.',
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(widget.redirectRoute ?? RoutesConstant.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
