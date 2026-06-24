import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';

/// Placeholder for the Account tab until the account feature is implemented.
class AccountPlaceholderPage extends StatelessWidget {
  const AccountPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Text(
            'Account settings coming soon.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
