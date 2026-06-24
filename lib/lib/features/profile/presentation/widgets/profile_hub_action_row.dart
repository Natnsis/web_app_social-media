import 'package:faithconnect/core/widgets/underline_tab_bar.dart';
import 'package:faithconnect/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Hub tabs: All (optional), Saved, Liked, Churches.
class ProfileHubActionRow extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool isChurchMode;

  const ProfileHubActionRow({
    super.key,
    this.selectedIndex = 0,
    required this.onChanged,
    this.isChurchMode = true,
  });

  static const _churchLabels = ['All', 'Saved', 'Liked', 'Churches'];
  static const _churchIcons = [
    Iconsax.cards,
    Icons.bookmark_rounded,
    Iconsax.heart,
    Iconsax.people,
  ];

  static const _memberLabels = ['Saved', 'Liked', 'Churches'];
  static const _memberIcons = [
    Icons.bookmark_rounded,
    Iconsax.heart,
    Iconsax.people,
  ];

  @override
  Widget build(BuildContext context) {
    return UnderlineTabBar(
      labels: isChurchMode ? _churchLabels : _memberLabels,
      icons: isChurchMode ? _churchIcons : _memberIcons,
      tooltips: isChurchMode ? _churchLabels : _memberLabels,
      selectedIndex: selectedIndex,
      onChanged: onChanged,
      selectedLabelColor: context.primary,
      indicatorColor: context.primary,
    );
  }
}
