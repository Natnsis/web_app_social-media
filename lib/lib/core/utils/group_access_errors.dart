/// Suppresses expected API errors when a user has not joined a group yet.
abstract final class GroupAccessErrors {
  GroupAccessErrors._();

  static bool isNonMemberMessage(String? message) {
    final normalized = message?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) return false;

    const patterns = [
      'must be a member',
      'must be member',
      'must be group member',
      'not a member',
      'not a group member',
      'non-member',
      'non member',
      'you must be',
      'member to see',
      'member to view',
      'member to access',
      'see this group',
      'see the group',
      'view this group',
      'view the group',
      'not authorized',
      'unauthorized',
      'access denied',
      'forbidden',
      'permission denied',
      'insufficient permission',
      'members only',
      'only members',
      'join the group',
      'join this group',
      'join first',
      'be a member',
      'church owner or a group moderator',
      'perform this action',
    ];

    return patterns.any(normalized.contains);
  }

  /// Returns [message] unless it is an expected non-member access error.
  static String? userFacingOrNull(String? message) {
    if (message == null || message.trim().isEmpty) return null;
    if (isNonMemberMessage(message)) return null;
    return message;
  }

  static String? firstSignificantError(Iterable<String?> messages) {
    for (final message in messages) {
      final userFacing = userFacingOrNull(message);
      if (userFacing != null) return userFacing;
    }
    return null;
  }
}
