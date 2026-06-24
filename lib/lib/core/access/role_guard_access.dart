import 'package:faithconnect/core/models/app_user_role.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_notifier.dart';

/// Resolved role capabilities for UI and route guards.
class RoleGuardAccess {
  final List<String> roles;
  final bool canManageChurchContent;
  final bool isChurchMode;
  final String roleLabel;

  const RoleGuardAccess({
    this.roles = const [],
    this.canManageChurchContent = false,
    this.isChurchMode = false,
    this.roleLabel = 'Community Member',
  });

  const RoleGuardAccess.guest() : this();

  factory RoleGuardAccess.from(HomeShellModeNotifier shellMode) {
    return RoleGuardAccess(
      roles: shellMode.roles,
      canManageChurchContent: shellMode.canManageChurchContent,
      isChurchMode: shellMode.isChurchMode,
      roleLabel: shellMode.roleLabel,
    );
  }

  /// Elevated church-admin capabilities (create post, group, campaign, go live).
  bool get showCreateActions => canManageChurchContent;

  /// `USER` + elevated role (e.g. `CHURCH_OWNER`) → full church-admin profile UI.
  bool get hasFullPrivileges => canManageChurchContent;

  /// Church-admin profile / settings UI — always on for elevated roles.
  bool get showChurchAdminUi => canManageChurchContent;

  /// Merges persisted shell roles with a fresher source (e.g. profile API user).
  RoleGuardAccess mergeRoles(List<String> additionalRoles) {
    return RoleGuardAccess.resolve(
      shellRoles: roles,
      profileRoles: additionalRoles,
      shellIsChurchMode: isChurchMode,
    );
  }

  /// Unified role resolution for pages that also have profile/API roles.
  static RoleGuardAccess resolve({
    required List<String> shellRoles,
    List<String> profileRoles = const [],
    bool shellIsChurchMode = false,
  }) {
    final merged = <String>{
      ...shellRoles.map((role) => role.toUpperCase()),
      ...profileRoles.map((role) => role.toUpperCase()),
    }.toList(growable: false);

    final canManage = UserRoleCapabilities.canManageChurchContent(merged);

    return RoleGuardAccess(
      roles: merged,
      canManageChurchContent: canManage,
      isChurchMode: canManage || shellIsChurchMode,
      roleLabel: UserRoleCapabilities.primaryRoleLabel(merged),
    );
  }

  bool meets(AppRoleRequirement requirement) {
    return switch (requirement) {
      AppRoleRequirement.elevated => hasFullPrivileges,
      AppRoleRequirement.authenticated => roles.isNotEmpty,
    };
  }

  static bool rolesMeet(
    AppRoleRequirement requirement,
    List<String> roles,
  ) {
    return switch (requirement) {
      AppRoleRequirement.elevated =>
        UserRoleCapabilities.canManageChurchContent(roles),
      AppRoleRequirement.authenticated => roles.isNotEmpty,
    };
  }
}

/// Role checks used by [RoleGuard] and [RoleGuardBuilder].
enum AppRoleRequirement {
  /// `CHURCH_OWNER`, `CHURCH_ADMIN`, `ADMIN`, or `SUPER_ADMIN`.
  elevated,

  /// Any signed-in user with persisted roles.
  authenticated,
}
