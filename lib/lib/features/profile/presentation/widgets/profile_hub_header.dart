import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/organization_profile.dart';
import 'package:faithconnect/features/profile/presentation/widgets/profile_hub_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileHubHeader extends StatelessWidget {
  final OrganizationProfile profile;
  final bool showOrganizationProfile;
  final String? accountMenuTitle;
  final String? memberDisplayName;
  final String? memberAvatarUrl;
  final String? memberEmail;
  final String? memberPhone;
  final VoidCallback? onBack;
  final VoidCallback? onSettings;
  final VoidCallback? onAccountMenu;
  final bool showThemeSwitch;
  final List<Widget>? trailingActions;
  final VoidCallback? onProfileTap;
  final VoidCallback? onAvatarTap;

  const ProfileHubHeader({
    super.key,
    required this.profile,
    this.showOrganizationProfile = true,
    this.accountMenuTitle,
    this.memberDisplayName,
    this.memberAvatarUrl,
    this.memberEmail,
    this.memberPhone,
    this.onBack,
    this.onSettings,
    this.onAccountMenu,
    this.showThemeSwitch = false,
    this.trailingActions,
    this.onProfileTap,
    this.onAvatarTap,
  });

  // String get _appBarTitle {
  //   if (!showOrganizationProfile) {
  //     return accountMenuTitle ?? memberDisplayName ?? 'My Account';
  //   }
  //   return accountMenuTitle ?? profile.owner.name;
  // }

  String get _profileTitle {
    if (!showOrganizationProfile) {
      return memberDisplayName ?? 'My Account';
    }
    return profile.name;
  }

  String get _profileBadgeLabel {
    if (!showOrganizationProfile) {
      final phone = memberPhone?.trim();
      if (phone != null && phone.isNotEmpty) {
        return phone;
      }
      final email = memberEmail?.trim();
      if (email != null && email.isNotEmpty) {
        return email;
      }
      return 'Personal profile';
    }
    return profile.hubLabel;
  }

  IconData get _profileBadgeIcon {
    if (!showOrganizationProfile) {
      final phone = memberPhone?.trim();
      if (phone != null && phone.isNotEmpty) {
        return Iconsax.call;
      }
      final email = memberEmail?.trim();
      if (email != null && email.isNotEmpty) {
        return Iconsax.sms;
      }
      return Iconsax.user;
    }
    return Iconsax.global;
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = 80.r;
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final headerTextColor = isDark ? Colors.white : colors.primaryText;
    final badgeIconColor = isDark ? Colors.white : colors.brandBlue;
    final badgeTextColor = isDark
        ? Colors.white.withValues(alpha: 0.88)
        : colors.secondaryText;
    final avatarIconColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : colors.mutedText;

    final showPersonalAvatar =
        !showOrganizationProfile || onAvatarTap != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(
          bottom: false,
          child: ProfileHubToolbar(
            title: '',
            onBack: onBack,
            onTitleTap: onAccountMenu,
            showTitleDropdown: onAccountMenu != null,
            showThemeSwitch: showThemeSwitch,
            onSettings: onSettings,
            centerTitle: true,
            useWhiteInDarkMode: true,
            trailingActions: trailingActions,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                if (showPersonalAvatar)
                  _ProfileAvatarWithEditAction(
                    onTap: onAvatarTap,
                  size: avatarSize,
                  child: _MemberProfileAvatar(
                    avatarUrl: memberAvatarUrl,
                    size: avatarSize,
                    placeholderIconColor: avatarIconColor,
                  ),
                )
              else
                _HubProfileAvatar(
                  profile: profile,
                  size: avatarSize,
                  placeholderIconColor: avatarIconColor,
                ),
              SizedBox(height: 12.h),
              _ProfileHubIdentity(
                onTap: onProfileTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _profileTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: headerTextColor,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width - 48.w,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : colors.tagBackground,
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : colors.divider,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _profileBadgeIcon,
                                size: 14.r,
                                color: badgeIconColor,
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  _profileBadgeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: badgeTextColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (onProfileTap != null) ...[
                                SizedBox(width: 4.w),
                                Icon(
                                  Iconsax.arrow_down_1,
                                  size: 14.r,
                                  color: badgeIconColor,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatarWithEditAction extends StatelessWidget {
  final Widget child;
  final double size;
  final VoidCallback? onTap;

  const _ProfileAvatarWithEditAction({
    required this.child,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;

    final colors = context.faithColors;
    final ringColor = context.isDarkMode
        ? colors.scaffoldBackground
        : colors.cardBackground;
    final badgeSize = 30.r;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + 6.w,
        height: size + 6.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: child,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: colors.brandBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Iconsax.edit_2,
                    size: 15.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHubIdentity extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _ProfileHubIdentity({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: child,
      ),
    );
  }
}

class _MemberProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final Color placeholderIconColor;

  const _MemberProfileAvatar({
    required this.avatarUrl,
    required this.size,
    required this.placeholderIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final ringColor = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.88)
        : colors.cardBackground;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2.5),
      ),
      child: ClipOval(child: _buildImage(context, size)),
    );
  }

  Widget _buildImage(BuildContext context, double size) {
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context, size),
      );
    }
    return _placeholder(context, size);
  }

  Widget _placeholder(BuildContext context, double size) {
    final colors = context.faithColors;
    return ColoredBox(
      color: colors.tagBackground,
      child: Icon(Iconsax.user, size: size * 0.4, color: placeholderIconColor),
    );
  }
}

class _HubProfileAvatar extends StatelessWidget {
  final OrganizationProfile profile;
  final double size;
  final Color placeholderIconColor;

  const _HubProfileAvatar({
    required this.profile,
    required this.size,
    required this.placeholderIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final ringColor = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.88)
        : colors.cardBackground;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2.5),
      ),
      child: ClipOval(child: _buildImage(context, size)),
    );
  }

  Widget _buildImage(BuildContext context, double size) {
    final url = profile.avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context, size),
      );
    }
    return _placeholder(context, size);
  }

  Widget _placeholder(BuildContext context, double size) {
    final colors = context.faithColors;
    return ColoredBox(
      color: colors.tagBackground,
      child: Icon(
        Iconsax.building,
        size: size * 0.4,
        color: placeholderIconColor,
      ),
    );
  }
}
