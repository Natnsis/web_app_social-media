import 'package:faithconnect/core/core.dart';

import 'package:faithconnect/features/profile/presentation/widgets/member_profile_summary.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';



/// Member personal profile: contact info, stats, and edit action.

class PersonalProfileCard extends StatelessWidget {
  final String? email;
  final String? phone;
  final String? churchName;
  final String? churchLogoUrl;
  final int savedCount;
  final int likedCount;
  final int followingCount;
  final bool showSummary;
  final VoidCallback? onEditProfile;

  const PersonalProfileCard({
    super.key,
    this.email,
    this.phone,
    this.churchName,
    this.churchLogoUrl,
    this.savedCount = 0,
    this.likedCount = 0,
    this.followingCount = 0,
    this.showSummary = true,
    this.onEditProfile,
  });



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;

    final isDark = context.isDarkMode;



    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onEditProfile,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : colors.divider,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (onEditProfile != null)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Personal details',
                            style: GoogleFonts.inter(
                              color: colors.primaryText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Iconsax.edit_2,
                          size: 18.r,
                          color: context.primary,
                        ),
                      ],
                    ),
                  if (onEditProfile != null) SizedBox(height: 12.h),
                  _ContactRow(
                    icon: Iconsax.sms,
                    label: 'Email',
                    value: _displayValue(email),
                  ),
                  SizedBox(height: 10.h),
                  _ContactRow(
                    icon: Iconsax.call,
                    label: 'Phone',
                    value: _displayValue(phone),
                  ),
                  if (churchName != null && churchName!.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    _ContactRow(
                      icon: Iconsax.house_2,
                      label: 'My Church',
                      value: churchName!,
                      imageUrl: churchLogoUrl,
                    ),
                  ],
                  if (onEditProfile != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      'Tap to edit name, bio, email, phone, and photo',
                      style: GoogleFonts.inter(
                        color: colors.mutedText,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showSummary) ...[
          SizedBox(height: 12.h),
          MemberProfileSummary(
            savedCount: savedCount,
            likedCount: likedCount,
            followingCount: followingCount,
          ),
        ],
      ],
    );

  }



  static String _displayValue(String? value) {

    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {

      return 'Not set';

    }

    return trimmed;

  }

}



class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? imageUrl;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isUnset = value == 'Not set';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: imageUrl != null && imageUrl!.trim().isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(icon, size: 18.r, color: context.primary),
                  ),
                )
              : Icon(icon, size: 18.r, color: context.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                label,

                style: GoogleFonts.inter(

                  color: colors.mutedText,

                  fontSize: 12.sp,

                  fontWeight: FontWeight.w500,

                ),

              ),

              SizedBox(height: 2.h),

              Text(

                value,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.inter(

                  color: isUnset

                      ? colors.mutedText.withValues(alpha: 0.7)

                      : colors.primaryText,

                  fontSize: 14.sp,

                  fontWeight: FontWeight.w600,

                  fontStyle: isUnset ? FontStyle.italic : FontStyle.normal,

                ),

              ),

            ],

          ),

        ),

      ],

    );

  }

}


