import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Returns `true` when the user confirms unfollow.
Future<bool> showUnfollowChurchDialog(
  BuildContext context, {
  required String churchName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Unfollow $churchName?'),
        content: const Text(
          'You will stop seeing updates from this church in your feed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Unfollow'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

/// Confirmation dialog wrapper used by [ConfirmationModal] styling.
void showUnfollowChurchConfirmation({
  required BuildContext context,
  required String churchName,
  required VoidCallback onConfirm,
}) {
  ConfirmationModal.show(
    context: context,
    title: 'Unfollow $churchName?',
    subtitle: 'You will stop seeing updates from this church in your feed.',
    confirmText: 'Unfollow',
    cancelText: 'Cancel',
    icon: Iconsax.user_minus,
    onConfirm: onConfirm,
  );
}
