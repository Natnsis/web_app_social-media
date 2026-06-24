import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/domain/access/church_edit_access.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_ids.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class ChurchNavigation {
  ChurchNavigation._();

  static Future<bool?> openEditChurchProfile(
    BuildContext context, {
    required String viewedProfileId,
    required ChurchProfile profile,
    String? associatedChurchId,
  }) {
    final access = context.readRoleAccess();
    if (!ChurchEditAccess.canEdit(
      access: access,
      viewedProfileId: viewedProfileId,
      profile: profile,
      associatedChurchId: associatedChurchId,
    )) {
      showInfo(
        context,
        'Only church administrators can edit their organization profile.',
      );
      return Future.value(null);
    }

    return context.pushNamed<bool>(
      RoutesConstant.editChurchProfile,
      pathParameters: {'id': profile.id},
      extra: profile,
    );
  }

  static void openMyChurchProfile(BuildContext context) {
    context.pushNamed(
      RoutesConstant.churchProfile,
      pathParameters: {'id': ChurchProfileIds.me},
    );
  }
}
