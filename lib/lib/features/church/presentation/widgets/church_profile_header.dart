import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile.dart';
import 'package:faithconnect/features/church/domain/entities/church_profile_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChurchProfileHeader extends StatelessWidget {
  final ChurchProfile profile;
  final ChurchProfileTab selectedTab;
  final String appBarTitle;
  final ValueChanged<ChurchProfileTab> onTabChanged;
  final VoidCallback onFollowTap;
  final VoidCallback? onBack;
  final VoidCallback? onLocationTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onEditTap;
  final bool showFollowAction;

  const ChurchProfileHeader({
    super.key,
    required this.profile,
    required this.selectedTab,
    required this.appBarTitle,
    required this.onTabChanged,
    required this.onFollowTap,
    this.showFollowAction = true,
    this.onBack,
    this.onLocationTap,
    this.onMessageTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final onBannerForeground = Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            ProfileBannerImage(
              imageUrl: profile.bannerUrl,
              extraTopInset: topInset,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.back,
                          color: onBannerForeground,
                          size: 22.r,
                        ),
                        onPressed:
                            onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          appBarTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: onBannerForeground,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.name,
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (profile.isVerified) ...[
                    SizedBox(width: 6.w),
                    const VerifiedBadge(size: 20),
                  ],
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                profile.bio,
                style: GoogleFonts.inter(
                  color: colors.mutedText,
                  fontSize: 14.sp,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  if (showFollowAction) ...[
                    Expanded(
                      child: PrimaryButton.feedAction(
                        text: profile.isFollowing ? 'Following' : 'Follow',
                        onPressed: onFollowTap,
                        width: double.infinity,
                        backgroundColor: profile.isFollowing
                            ? colors.tagBackground
                            : null,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ] else if (onEditTap != null) ...[
                    Expanded(
                      child: PrimaryButton.outlinedAction(
                        text: 'Edit Profile',
                        onPressed: onEditTap,
                        width: double.infinity,
                        iconData: Iconsax.edit_2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  if (onMessageTap != null) ...[
                    Expanded(
                      child: PrimaryButton.outlinedAction(
                        text: 'Message',
                        onPressed: onMessageTap,
                        width: double.infinity,
                        iconData: Iconsax.message,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Expanded(
                    child: PrimaryButton.outlinedAction(
                      text: 'Location',
                      onPressed: onLocationTap,
                      width: double.infinity,
                      iconData: Icons.location_on_outlined,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              UnderlineTabBar(
                labels: ChurchProfileTabX.valuesOrdered
                    .map((t) => t.label)
                    .toList(),
                selectedIndex: selectedTab.index,
                onChanged: (index) =>
                    onTabChanged(ChurchProfileTabX.valuesOrdered[index]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final Color borderColor;

  const _ProfileAvatar({
    required this.imageUrl,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppAvatar(imageUrl: imageUrl, size: 88),
    );
  }
}
