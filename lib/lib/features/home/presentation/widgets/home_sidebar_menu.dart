import 'package:faithconnect/core/access/role_guard_access.dart';
import 'package:faithconnect/core/models/app_user_role.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum HomeSidebarNavAction {
  home,
  accountOverview,
  discovery,
  groups,
  campaign,
  gift,
  language,
  analytics,
  payouts,
  moderation,
}

class HomeSidebarNavItem {
  final HomeSidebarNavAction action;
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final AppRoleRequirement requirement;
  final Color? iconColor;

  const HomeSidebarNavItem({
    required this.action,
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.requirement = AppRoleRequirement.authenticated,
    this.iconColor,
  });

  bool isVisible(RoleGuardAccess access) => access.meets(requirement);
}

class HomeSidebarMenuSection {
  final String title;
  final List<HomeSidebarNavItem> items;
  final bool channelStyle;

  const HomeSidebarMenuSection({
    required this.title,
    required this.items,
    this.channelStyle = false,
  });

  List<HomeSidebarNavItem> visibleItems(RoleGuardAccess access) {
    return items
        .where((item) => item.isVisible(access))
        .toList(growable: false);
  }
}

/// Role-aware sidebar sections; widgets stay in [HomeSidebarDrawer].
abstract final class HomeSidebarMenu {
  HomeSidebarMenu._();

  static const homeBranchIndex = 0;
  static const groupsBranchIndex = 1;
  static const accountBranchIndex = 3;

  static List<HomeSidebarMenuSection> sectionsFor(RoleGuardAccess access) {
    return [
      HomeSidebarMenuSection(
        title: 'DISCOVER',
        items: [
          HomeSidebarNavItem(
            action: HomeSidebarNavAction.home,
            icon: Iconsax.home_2,
            selectedIcon: Iconsax.home_2_copy,
            label: 'Home',
          ),
          HomeSidebarNavItem(
            action: HomeSidebarNavAction.accountOverview,
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view_rounded,
            label: 'Account Overview',
            requirement: AppRoleRequirement.elevated,
          ),
          HomeSidebarNavItem(
            action: HomeSidebarNavAction.discovery,
            icon: Icons.explore_outlined,
            label: 'Discovery',
          ),
        ],
      ),
      HomeSidebarMenuSection(
        title: 'COMMUNITY',
        items: [
          HomeSidebarNavItem(
            action: HomeSidebarNavAction.campaign,
            icon: Icons.campaign_outlined,
            label: 'Campaign',
          ),
          HomeSidebarNavItem(
            action: HomeSidebarNavAction.groups,
            icon: Icons.group,
            label: 'Groups',
          ),
          HomeSidebarNavItem(
            action: HomeSidebarNavAction.gift,
            icon: Icons.volunteer_activism_outlined,
            label: 'Gift',
          ),
        ],
      ),
      HomeSidebarMenuSection(
        title: 'PREFERENCES',
        items: [
          HomeSidebarNavItem(
            action: HomeSidebarNavAction.language,
            icon: Iconsax.language_circle,
            label: 'Language',
          ),
        ],
      ),
      if (access.showChurchAdminUi)
        HomeSidebarMenuSection(
          title: 'CHANNEL',
          channelStyle: true,
          items: const [
            HomeSidebarNavItem(
              action: HomeSidebarNavAction.analytics,
              icon: Icons.show_chart_rounded,
              label: 'Analytics',
              requirement: AppRoleRequirement.elevated,
            ),

            HomeSidebarNavItem(
              action: HomeSidebarNavAction.moderation,
              icon: Icons.gavel_outlined,
              label: 'Moderation',
              requirement: AppRoleRequirement.elevated,
            ),
          ],
        ),
    ];
  }

  static String organizationName({
    required RoleGuardAccess access,
    String? churchName,
  }) {
    final trimmed = churchName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    if (access.showChurchAdminUi) return 'My Organization';
    return '';
  }

  static String organizationBadge(RoleGuardAccess access) {
    return UserRoleCapabilities.organizationBadgeLabel(access.roles);
  }
}
