/// API role strings from auth responses (`data.roles`).
abstract final class AppUserRole {
  AppUserRole._();

  static const user = 'USER';

  static const churchAdmin = 'CHURCH_ADMIN';
  static const churchOwner = 'CHURCH_OWNER';
  static const admin = 'ADMIN';
  static const superAdmin = 'SUPER_ADMIN';

  static const elevatedRoles = <String>{
    churchAdmin,
    churchOwner,
    admin,
    superAdmin,
  };

  static List<String> normalizeList(Iterable<dynamic>? raw) {
    if (raw == null) return const [];
    final normalized = <String>{};
    for (final entry in raw) {
      final role = parseRoleValue(entry);
      if (role != null) normalized.add(role);
    }
    return normalized.toList(growable: false);
  }

  /// Parses a role string or `{ "role": "CHURCH_OWNER" }` style object.
  static String? parseRoleValue(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return trimmed.replaceAll(RegExp(r'[\s-]+'), '_').toUpperCase();
    }

    if (value is Map) {
      for (final key in ['role', 'name', 'type', 'code', 'value']) {
        final nested = value[key];
        if (nested is String && nested.trim().isNotEmpty) {
          return nested.trim().replaceAll(RegExp(r'[\s-]+'), '_').toUpperCase();
        }
      }
    }

    return null;
  }

  /// Collects all role strings from a user/profile API map.
  static List<String> collectFromMap(Map<String, dynamic> json) {
    final normalized = <String>{};

    void addRaw(Iterable<dynamic>? raw) {
      normalized.addAll(normalizeList(raw));
    }

    addRaw(json['roles'] as List<dynamic>?);
    addRaw(json['userRoles'] as List<dynamic>?);
    addRaw(json['user_roles'] as List<dynamic>?);

    for (final key in [
      'role',
      'userType',
      'user_type',
      'accountType',
      'account_type',
    ]) {
      final parsed = parseRoleValue(json[key]);
      if (parsed != null) normalized.add(parsed);
    }

    if (json['isChurchOwner'] == true ||
        json['isChurchAdmin'] == true ||
        json['is_church_owner'] == true ||
        json['is_church_admin'] == true) {
      normalized.add(churchOwner);
    }

    final church = json['church'];
    if (church is Map) {
      final churchMap = Map<String, dynamic>.from(church);
      addRaw(churchMap['roles'] as List<dynamic>?);
      final churchRole =
          parseRoleValue(churchMap['role']) ??
          parseRoleValue(churchMap['membershipRole']) ??
          parseRoleValue(json['churchRole']) ??
          parseRoleValue(json['church_role']);
      if (churchRole != null) normalized.add(churchRole);
    }

    return normalized.toList(growable: false);
  }
}

/// Feature gates derived from persisted auth roles.
abstract final class UserRoleCapabilities {
  UserRoleCapabilities._();

  /// True when any elevated role is present (e.g. `USER` + `CHURCH_OWNER`).
  static bool canManageChurchContent(List<String> roles) {
    if (roles.isEmpty) return false;
    final normalized = roles.map((r) => r.toUpperCase()).toSet();
    return normalized.any(AppUserRole.elevatedRoles.contains);
  }

  /// Alias — elevated roles always receive full app privileges.
  static bool hasFullPrivileges(List<String> roles) =>
      canManageChurchContent(roles);

  static bool isCommunityMemberOnly(List<String> roles) {
    if (roles.isEmpty) return true;
    final normalized = roles.map((r) => r.toUpperCase()).toSet();
    return !canManageChurchContent(roles) &&
        normalized.contains(AppUserRole.user);
  }

  static String primaryRoleLabel(List<String> roles) {
    if (canManageChurchContent(roles)) {
      return 'Church Administrator';
    }
    return 'Community Member';
  }

  /// Short badge for the sidebar organization chip.
  static String organizationBadgeLabel(List<String> roles) {
    final normalized = roles.map((r) => r.toUpperCase()).toSet();
    if (normalized.contains(AppUserRole.superAdmin)) return 'SUPER';
    if (normalized.contains(AppUserRole.admin)) return 'ADMIN';
    if (normalized.contains(AppUserRole.churchOwner)) return 'OWNER';
    if (normalized.contains(AppUserRole.churchAdmin)) return 'ADMIN';
    return 'ADMIN';
  }
}
