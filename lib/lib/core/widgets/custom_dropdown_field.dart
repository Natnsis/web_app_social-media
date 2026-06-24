import 'package:flutter/material.dart';
import 'package:faithconnect/core/theme/dark_theme.dart';

class CustomDropdownField extends StatelessWidget {
  final String? label;
  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  final String? Function(String?)? validator;

  const CustomDropdownField({
    super.key,
    this.label,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark
        ? DarkTheme.feedMutedText
        : theme.colorScheme.onSurfaceVariant;
    final fillColor = isDark
        ? DarkTheme.authFieldFill
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final borderColor = isDark
        ? DarkTheme.authFieldBorder
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15);

    final dropdown = DropdownButtonFormField<String>(
      initialValue: value,
      validator: validator,
      dropdownColor:
          isDark ? DarkTheme.feedCardBackground : theme.colorScheme.surface,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.white : null,
      ),
      hint: Text(
        hint,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: mutedColor.withValues(alpha: 0.75),
        ),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
      items: items.map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
    );

    if (label == null) {
      return dropdown;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: theme.textTheme.labelMedium?.copyWith(
            color: mutedColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        dropdown,
      ],
    );
  }
}
