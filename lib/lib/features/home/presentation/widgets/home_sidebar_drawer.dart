import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:faithconnect/features/campaign/presentation/navigation/campaign_navigation.dart';
import 'package:faithconnect/features/chat/presentation/navigation/groups_navigation.dart';
import 'package:faithconnect/features/discovery/presentation/navigation/discovery_navigation.dart';
import 'package:faithconnect/features/home/gift/presentation/navigation/gift_navigation.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_event.dart';
import 'package:faithconnect/features/auth/presentation/blocs/auth_state.dart';
import 'package:faithconnect/features/auth/presentation/navigation/language_navigation.dart';
import 'package:faithconnect/features/home/presentation/home_shell_mode_scope.dart';
import 'package:faithconnect/features/home/presentation/widgets/home_sidebar_menu.dart';
import 'package:faithconnect/features/profile/presentation/pages/analytics.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_state.dart';

/// Left navigation drawer for the home shell (Pastor / admin sidebar).
class HomeSidebarDrawer extends StatefulWidget {
  const HomeSidebarDrawer({super.key});

  @override
  State<HomeSidebarDrawer> createState() => _HomeSidebarDrawerState();
}

class _HomeSidebarDrawerState extends State<HomeSidebarDrawer> {
  String _userName = 'Community Member';
  String? _avatarUrl;
  String? _churchName;
  List<String> _profileRoles = const [];
  bool _profileLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_profileLoaded) {
      _profileLoaded = true;
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    final user = await SharedPrefsService.getUser();
    if (!mounted) return;

    setState(() {
      final name = user?.name?.trim();
      _userName = (name != null && name.isNotEmpty) ? name : 'Community Member';
      _avatarUrl = user?.avatar;
      _churchName = user?.churchName;
      _profileRoles = user?.roles ?? const [];
    });

    final shellMode = HomeShellModeScope.maybeOf(context);
    if (shellMode != null && _profileRoles.isNotEmpty) {
      await shellMode.applyUserRoles(_profileRoles);
    }
  }

  void _close() => Navigator.of(context).pop();

  void _goToShellBranch(int index) {
    _close();
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      shell.goBranch(index, initialLocation: index == shell.currentIndex);
      return;
    }
    final routes = [
      RoutesConstant.home,
      RoutesConstant.chatList,
      RoutesConstant.shorts,
      RoutesConstant.account,
    ];
    if (index >= 0 && index < routes.length) {
      context.go(routes[index]);
    }
  }

  Future<void> _logout() async {
    _close();
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  void _showComingSoon(String label) {
    _close();
    showInfo(context, '$label coming soon');
  }

  void _openAccountSettings() {
    _close();
    context.pushNamed(RoutesConstant.accountSettings);
  }

  void _openLanguage() {
    _close();
    LanguageNavigation.openLanguage(context);
  }

  void _openModerators() {
    _close();
    context.pushNamed(RoutesConstant.churchModerators);
  }

  int _currentShellIndex(BuildContext context) {
    return StatefulNavigationShell.maybeOf(context)?.currentIndex ?? 0;
  }

  void _onNavItemTap(HomeSidebarNavItem item, {required int currentIndex}) {
    switch (item.action) {
      case HomeSidebarNavAction.home:
        _goToShellBranch(HomeSidebarMenu.homeBranchIndex);
      case HomeSidebarNavAction.accountOverview:
        _goToShellBranch(HomeSidebarMenu.accountBranchIndex);
      case HomeSidebarNavAction.discovery:
        _close();
        DiscoveryNavigation.openDiscovery(context);
      case HomeSidebarNavAction.groups:
        _close();
        GroupsNavigation.openGroups(context);
      case HomeSidebarNavAction.campaign:
        _close();
        CampaignNavigation.openHub(context);
      case HomeSidebarNavAction.gift:
        Navigator.of(context).pop();
        GiftNavigation.openGift(context);
      case HomeSidebarNavAction.language:
        _openLanguage();
      case HomeSidebarNavAction.analytics:
        _close();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => sl<AccountProfileBloc>(),
              child: const Analytics(),
            ),
          ),
        );
      case HomeSidebarNavAction.payouts:
        _showComingSoon('Payouts');
      case HomeSidebarNavAction.moderation:
        _openModerators();
    }
  }

  bool _isNavItemSelected(HomeSidebarNavItem item, int currentIndex) {
    return switch (item.action) {
      HomeSidebarNavAction.home =>
        currentIndex == HomeSidebarMenu.homeBranchIndex,
      HomeSidebarNavAction.accountOverview =>
        currentIndex == HomeSidebarMenu.accountBranchIndex,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shellMode = HomeShellModeScope.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(RoutesConstant.login);
        }
      },
      child: RoleGuardBuilder(
        builder: (context, shellAccess) {
          return ListenableBuilder(
            listenable: shellMode,
            builder: (context, _) {
              final access = RoleGuardAccess.resolve(
                shellRoles: shellAccess.roles,
                profileRoles: _profileRoles,
                shellIsChurchMode: shellMode.isChurchMode,
              );
              final currentIndex = _currentShellIndex(context);
              final sections = HomeSidebarMenu.sectionsFor(access);
              final showOrgChip = access.showChurchAdminUi;
              final orgName = HomeSidebarMenu.organizationName(
                access: access,
                churchName: _churchName,
              );

              return Drawer(
                width: 0.86.sw.clamp(280.0, 340.0),
                backgroundColor: isDark
                    ? DarkTheme.sidebarBackground
                    : theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SidebarHeader(
                        name: _userName,
                        role: access.roleLabel,
                        avatarUrl: _avatarUrl,
                        onClose: _close,
                      ),
                      if (showOrgChip && orgName.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _OrganizationChip(
                          name: orgName,
                          badgeLabel: HomeSidebarMenu.organizationBadge(access),
                        ),
                      ] else
                        SizedBox(height: 16.h),
                      SizedBox(height: 12.h),
                      const _WalletBalanceWidget(),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          children: [
                            for (var i = 0; i < sections.length; i++) ...[
                              if (i > 0) SizedBox(height: 20.h),
                              _SidebarMenuSectionView(
                                section: sections[i],
                                access: access,
                                currentIndex: currentIndex,
                                onItemTap: (item) => _onNavItemTap(
                                  item,
                                  currentIndex: currentIndex,
                                ),
                                isSelected: (item) =>
                                    _isNavItemSelected(item, currentIndex),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _SidebarFooter(
                        onSettings: access.showChurchAdminUi
                            ? _openAccountSettings
                            : () => _showComingSoon('Settings'),
                        onLogout: _logout,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SidebarMenuSectionView extends StatelessWidget {
  final HomeSidebarMenuSection section;
  final RoleGuardAccess access;
  final int currentIndex;
  final void Function(HomeSidebarNavItem item) onItemTap;
  final bool Function(HomeSidebarNavItem item) isSelected;

  const _SidebarMenuSectionView({
    required this.section,
    required this.access,
    required this.currentIndex,
    required this.onItemTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = section.visibleItems(access);
    if (items.isEmpty) return const SizedBox.shrink();

    final tiles = items.map((item) {
      final selected = isSelected(item);
      final isLanguage = item.action == HomeSidebarNavAction.language;
      final isChannel = section.channelStyle;

      Widget tile(String? trailing, {Color? iconColor}) => _SidebarNavTile(
        icon: selected && item.selectedIcon != null
            ? item.selectedIcon!
            : item.icon,
        label: item.label,
        isSelected: selected,
        iconColor: isChannel
            ? DarkTheme.sidebarSelected
            : (iconColor ?? item.iconColor),
        trailing: trailing,
        onTap: () => onItemTap(item),
      );

      if (isLanguage) {
        return BlocBuilder<LocaleCubit, AppLanguage>(
          builder: (context, language) =>
              tile(language.label, iconColor: context.primary),
        );
      }

      return tile(null);
    }).toList();

    if (section.channelStyle) {
      return _ChannelSection(children: tiles);
    }

    return _SidebarSection(title: section.title, children: tiles);
  }
}

class _SidebarHeader extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;
  final VoidCallback onClose;

  const _SidebarHeader({
    required this.name,
    required this.role,
    this.avatarUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark
        ? DarkTheme.sidebarSurface
        : theme.colorScheme.surfaceContainerHighest;
    final itemTextColor = isDark
        ? DarkTheme.sidebarItemText
        : theme.colorScheme.onSurfaceVariant;
    final nameColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: surfaceColor,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Icon(Icons.person, color: itemTextColor, size: 28.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: nameColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  role,
                  style: GoogleFonts.inter(
                    color: itemTextColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: itemTextColor, size: 22.sp),
            style: IconButton.styleFrom(
              backgroundColor: surfaceColor,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationChip extends StatelessWidget {
  final String name;
  final String badgeLabel;

  const _OrganizationChip({required this.name, required this.badgeLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark
        ? DarkTheme.sidebarSurface
        : theme.colorScheme.surfaceContainerHighest;
    final itemTextColor = isDark
        ? DarkTheme.sidebarItemText
        : theme.colorScheme.onSurfaceVariant;
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final badgeColor = isDark
        ? DarkTheme.sidebarAdminBadge
        : DarkTheme.brandBlue;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            Icon(Icons.church_outlined, color: itemTextColor, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  color: titleColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                badgeLabel,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletBalanceWidget extends StatelessWidget {
  const _WalletBalanceWidget();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WalletBloc>()..add(const FetchChurchWalletBalance()),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final surfaceColor = isDark
              ? DarkTheme.sidebarSurface
              : theme.colorScheme.surfaceContainerHighest;
          final itemTextColor = isDark
              ? DarkTheme.sidebarItemText
              : theme.colorScheme.onSurfaceVariant;
          final titleColor = isDark
              ? Colors.white
              : theme.colorScheme.onSurface;
          final iconColor = isDark
              ? DarkTheme.brandBlue
              : theme.colorScheme.primary;

          final wallet = state.churchWallet;
          final isLoading =
              state.status == WalletStatus.loading && wallet == null;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Material(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16.r),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // Close drawer
                  context.push(RoutesConstant.wallet);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: iconColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Balance',
                              style: GoogleFonts.inter(
                                color: itemTextColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            if (isLoading)
                              Shimmer.fromColors(
                                baseColor: isDark
                                    ? Colors.white24
                                    : const Color(0xFFE0E0E0),
                                highlightColor: isDark
                                    ? Colors.white60
                                    : const Color(0xFFF5F5F5),
                                child: Container(
                                  height: 18.sp,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              )
                            else
                              Text(
                                wallet != null
                                    ? 'ETB ${NumberFormat('#,##0.00').format(wallet.balanceEtb)}'
                                    : 'ETB 0.00',
                                style: GoogleFonts.inter(
                                  color: titleColor,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SidebarSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionColor = isDark
        ? DarkTheme.sidebarSectionLabel
        : theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: sectionColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _ChannelSection extends StatelessWidget {
  final List<Widget> children;

  const _ChannelSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionColor = isDark
        ? DarkTheme.sidebarSectionLabel
        : theme.colorScheme.onSurfaceVariant;
    final cardColor = isDark
        ? DarkTheme.sidebarSurfaceElevated
        : theme.colorScheme.surfaceContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            'CHANNEL',
            style: GoogleFonts.inter(
              color: sectionColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? iconColor;
  final String? trailing;

  const _SidebarNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemTextColor = isDark
        ? DarkTheme.sidebarItemText
        : theme.colorScheme.onSurfaceVariant;
    final selectedColor = isDark
        ? DarkTheme.sidebarSelected
        : DarkTheme.brandBlue;
    final effectiveIconColor = isSelected
        ? Colors.white
        : (iconColor ?? itemTextColor);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Material(
        color: isSelected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            child: Row(
              children: [
                Icon(icon, size: 22.sp, color: effectiveIconColor),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : itemTextColor,
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  Text(
                    trailing!,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : itemTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : itemTextColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _SidebarFooter({required this.onSettings, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemTextColor = isDark
        ? DarkTheme.sidebarItemText
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          InkWell(
            onTap: onSettings,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      color: itemTextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onLogout,
            icon: Icon(Icons.logout_rounded, color: itemTextColor, size: 22.sp),
            tooltip: 'Log out',
          ),
        ],
      ),
    );
  }
}
