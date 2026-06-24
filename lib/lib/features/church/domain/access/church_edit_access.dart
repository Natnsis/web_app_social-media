import 'package:faithconnect/core/access/role_guard_access.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_ids.dart';

/// Whether the signed-in user may edit a church profile.
abstract final class ChurchEditAccess {
  ChurchEditAccess._();

  static bool canEdit({
    required RoleGuardAccess access,
    required String viewedProfileId,
    required ChurchProfile profile,
    String? associatedChurchId,
  }) {
    if (!access.canManageChurchContent) return false;

    if (ChurchProfileIds.isMyChurch(viewedProfileId)) return true;

    final churchId = profile.id.trim();
    final linkedId = associatedChurchId?.trim();
    if (linkedId != null && linkedId.isNotEmpty && churchId == linkedId) {
      return true;
    }

    return false;
  }

  static bool canEditChurchId({
    required RoleGuardAccess access,
    required String churchId,
    String? associatedChurchId,
  }) {
    if (!access.canManageChurchContent) return false;

    final targetId = churchId.trim();
    final linkedId = associatedChurchId?.trim();
    if (targetId.isEmpty || linkedId == null || linkedId.isEmpty) return false;

    return targetId == linkedId;
  }
}
