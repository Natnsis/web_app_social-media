import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/injection.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_bloc.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_event.dart';
import 'package:faithconnect/features/profile/presentation/bloc/account_profile_state.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_bloc.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_event.dart';
import 'package:faithconnect/features/church/presentation/bloc/church_moderators_state.dart';
import 'package:faithconnect/features/profile/presentation/widgets/account_settings_section.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:faithconnect/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:faithconnect/features/wallet/presentation/widgets/payment_accounts_bottom_sheet.dart';
import 'package:faithconnect/features/notifications/application/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _notificationsEnabled = true;
  int? _followingCount;

  @override
  void initState() {
    super.initState();
    final state = context.read<AccountProfileBloc>().state;
    if (state is! AccountProfileLoaded) {
      context.read<AccountProfileBloc>().add(const AccountProfileRequested());
    }
    _loadFollowingCount();
    _loadNotificationPreferences();
  }

  Future<void> _loadFollowingCount() async {
    final result = await sl<ChurchService>().getFollowingChurches(limit: 1);
    if (!mounted) return;
    result.fold(
      (_) {},
      (page) => setState(() => _followingCount = page.meta.total),
    );
  }

  Future<void> _loadNotificationPreferences() async {
    final result = await sl<NotificationsService>().getPreferences();
    if (!mounted) return;
    result.fold(
      (_) {},
      (prefs) => setState(() => _notificationsEnabled = prefs.pushNotifications),
    );
  }

  void _showComingSoon(String label) {
    showInfo(context, '$label coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: const ProfileHubAppBar(
        title: 'Accounts Settings',
        useWhiteInDarkMode: true,
      ),
      body: BlocProvider(
        create: (context) =>
            sl<WalletBloc>()..add(const FetchChurchWalletBalance()),
        child: BlocBuilder<AccountProfileBloc, AccountProfileState>(
          builder: (context, state) {
            if (state is AccountProfileLoading) {
              return Center(
                child: CircularProgressIndicator(color: colors.brandBlue),
              );
            }

            if (state is AccountProfileFailure) {
              return Center(
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.primaryText),
                      ),
                      AppSpacing.v16,
                      PrimaryButton.feedAction(
                        text: 'Retry',
                        onPressed: () => context.read<AccountProfileBloc>().add(
                          const AccountProfileRequested(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is! AccountProfileLoaded) {
              return const SizedBox.shrink();
            }

            return RoleGuardBuilder(
              builder: (context, access) {
                final userRoles = state.currentUser?.roles ?? const <String>[];
                final effective = RoleGuardAccess.resolve(
                  shellRoles: access.roles,
                  profileRoles: userRoles,
                  shellIsChurchMode: access.isChurchMode,
                );
                return _AccountSettingsBody(
                  stats: state.profile.stats,
                  followingCount: _followingCount,
                  isChurchMode: effective.showChurchAdminUi,
                  notificationsEnabled: _notificationsEnabled,
                  onNotificationsChanged: (value) {
                    if (!value) {
                      NotificationDisableDialog.show(
                        context: context,
                        onConfirm: () async {
                          final result = await sl<NotificationsService>().unregisterDeviceToken();
                          if (mounted) {
                            result.fold(
                              (failure) => showError(context, failure.message),
                              (_) async {
                                setState(() => _notificationsEnabled = false);
                                showSuccess(context, 'Notifications disabled successfully');
                                final prefsRes = await sl<NotificationsService>().getPreferences();
                                prefsRes.fold(
                                  (_) {},
                                  (prefs) => sl<NotificationsService>().updatePreferences(
                                    prefs.copyWith(pushNotifications: false),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      );
                    } else {
                      setState(() => _notificationsEnabled = true);
                      sl<NotificationsService>().registerDeviceToken().then((result) {
                        if (mounted) {
                          result.fold(
                            (failure) {
                              setState(() => _notificationsEnabled = false);
                              showError(context, failure.message);
                            },
                            (_) async {
                              showSuccess(context, 'Notifications enabled successfully');
                              final prefsRes = await sl<NotificationsService>().getPreferences();
                              prefsRes.fold(
                                (_) {},
                                (prefs) => sl<NotificationsService>().updatePreferences(
                                  prefs.copyWith(pushNotifications: true),
                                ),
                              );
                            },
                          );
                        }
                      });
                    }
                  },
                  onShowComingSoon: _showComingSoon,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AccountSettingsBody extends StatelessWidget {
  final ProfileStats stats;
  final int? followingCount;
  final bool isChurchMode;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final void Function(String) onShowComingSoon;

  const _AccountSettingsBody({
    required this.stats,
    this.followingCount,
    required this.isChurchMode,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onShowComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        if (isChurchMode) ...[
          SizedBox(height: 28.h),
          AccountSettingsSection(
            title: 'Financial & Administration',
            children: [
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, walletState) {
                  final accounts = walletState.paymentAccounts ?? [];
                  final primaryAccount = accounts.isNotEmpty
                      ? accounts.first
                      : null;

                  return AppCompactCardTile(
                    icon: Iconsax.bank,
                    title: 'Bank & Payout',
                    subtitle: primaryAccount != null
                        ? 'Linked: ${primaryAccount.provider} ****${primaryAccount.accountNumber.length > 4 ? primaryAccount.accountNumber.substring(primaryAccount.accountNumber.length - 4) : primaryAccount.accountNumber}'
                        : 'No account linked',
                    iconBackgroundColor: colors.brandBlue.withValues(
                      alpha: 0.15,
                    ),
                    iconColor: colors.brandBlue,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colors.iconMuted,
                      size: 22.r,
                    ),
                    onTap: () => PaymentAccountsBottomSheet.show(
                      context,
                      context.read<WalletBloc>(),
                    ),
                  );
                },
              ),
              const AccountSettingsSectionGap(),

              BlocProvider(
                create: (context) => sl<ChurchModeratorsBloc>()..add(const ChurchModeratorsRequested()),
                child: BlocBuilder<ChurchModeratorsBloc, ChurchModeratorsState>(
                  builder: (context, modState) {
                    final rolesCount = modState is ChurchModeratorsLoaded 
                        ? modState.members.length 
                        : 0;
                    final subtitle = modState is ChurchModeratorsLoading 
                        ? 'Loading...' 
                        : '$rolesCount ${rolesCount == 1 ? 'role' : 'roles'} assigned';

                    return AppCompactCardTile(
                      icon: Iconsax.user_cirlce_add,
                      title: 'Manage Admins',
                      subtitle: subtitle,
                      iconBackgroundColor: colors.brandBlue.withValues(alpha: 0.15),
                      iconColor: colors.brandBlue,
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.iconMuted,
                        size: 22.r,
                      ),
                      onTap: () => context.pushNamed(RoutesConstant.churchModerators),
                    );
                  },
                ),
              ),
              const AccountSettingsSectionGap(),
              AppCompactCardTile(
                icon: Icons.show_chart_rounded,
                title: 'Analytics',
                subtitle: 'View page insights and engagement',
                iconBackgroundColor: colors.brandBlue.withValues(alpha: 0.15),
                iconColor: colors.brandBlue,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.iconMuted,
                  size: 22.r,
                ),
                onTap: () => context.pushNamed(RoutesConstant.analytics),
              ),
              const AccountSettingsSectionGap(),
            ],
          ),
          SizedBox(height: 28.h),
        ],
        AccountSettingsSection(
          title: 'Personal Preferences',
          children: [
            AppCompactCard(
              borderRadius: 24,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: colors.brandBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.notification,
                      color: colors.brandBlue,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: notificationsEnabled,
                    onChanged: onNotificationsChanged,
                    activeTrackColor: colors.brandBlue,
                    activeThumbColor: Colors.white,
                    inactiveTrackColor: colors.tagBackground,
                    inactiveThumbColor: colors.mutedText,
                  ),
                ],
              ),
            ),
            const AccountSettingsSectionGap(),
            AppCompactCardTile(
              icon: Iconsax.shield_tick,
              title: 'Privacy & Security',
              subtitle: 'Password, sessions, and data',
              iconBackgroundColor: colors.brandBlue.withValues(alpha: 0.15),
              iconColor: colors.brandBlue,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colors.iconMuted,
                size: 22.r,
              ),
              onTap: () => onShowComingSoon('Privacy & Security'),
            ),
          ],
        ),
      ],
    );
  }
}
