import 'package:faithconnect/core/widgets/role_guard.dart';
import 'package:flutter/material.dart';

/// Blocks church-admin create flows when the account has no elevated role.
class ChurchContentGuard extends StatelessWidget {
  final Widget child;

  const ChurchContentGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requirement: AppRoleRequirement.elevated,
      behavior: RoleGuardBehavior.redirect,
      child: child,
    );
  }
}
