import 'package:faithconnect/core/core.dart';

import 'package:faithconnect/features/church/domain/entities/church_profile_group.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';



class ChurchProfileGroupsContent {

  ChurchProfileGroupsContent._();



  static List<Widget> buildSlivers({

    required List<ChurchProfileGroup> groups,

    required ValueChanged<ChurchProfileGroup> onGroupTap,

    bool isMyChurch = false,

  }) {

    return [

      SliverPadding(

        padding: EdgeInsets.symmetric(horizontal: 16.w),

        sliver: SliverList.separated(

          itemCount: groups.length,

          separatorBuilder: (_, _) => SizedBox(height: 10.h),

          itemBuilder: (context, index) {

            return _GroupTile(

              group: groups[index],

              isMyChurch: isMyChurch,

              onTap: () => onGroupTap(groups[index]),

            );

          },

        ),

      ),

    ];

  }

}



class _GroupTile extends StatelessWidget {

  final ChurchProfileGroup group;

  final bool isMyChurch;

  final VoidCallback onTap;



  const _GroupTile({

    required this.group,

    required this.isMyChurch,

    required this.onTap,

  });



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;

    final actionLabel = isMyChurch ? 'Manage requests' : 'Request to join';



    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(16.r),

        child: AppCompactCard(

          padding: EdgeInsets.all(12.w),

          child: Row(

            children: [

              ClipRRect(

                borderRadius: BorderRadius.circular(12.r),

                child: SizedBox(

                  width: 56.w,

                  height: 56.w,

                  child: group.coverImageUrl != null

                      ? Image.network(

                          group.coverImageUrl!,

                          fit: BoxFit.cover,

                          errorBuilder: (_, _, _) => _fallback(colors),

                        )

                      : _fallback(colors),

                ),

              ),

              SizedBox(width: 12.w),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        Flexible(

                          child: Text(

                            group.name,

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: GoogleFonts.inter(

                              color: colors.primaryText,

                              fontSize: 15.sp,

                              fontWeight: FontWeight.w600,

                            ),

                          ),

                        ),

                        if (group.isPrivate) ...[

                          SizedBox(width: 6.w),

                          Icon(

                            Iconsax.lock,

                            size: 14.r,

                            color: colors.mutedText,

                          ),

                        ],

                      ],

                    ),

                    if (group.description != null &&

                        group.description!.trim().isNotEmpty) ...[

                      SizedBox(height: 4.h),

                      Text(

                        group.description!,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.inter(

                          color: colors.mutedText,

                          fontSize: 12.sp,

                        ),

                      ),

                    ],

                    SizedBox(height: 4.h),

                    Text(

                      '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',

                      style: GoogleFonts.inter(

                        color: colors.mutedText,

                        fontSize: 11.sp,

                      ),

                    ),

                    SizedBox(height: 6.h),

                    Text(

                      actionLabel,

                      style: GoogleFonts.inter(

                        color: colors.brandBlue,

                        fontSize: 12.sp,

                        fontWeight: FontWeight.w600,

                      ),

                    ),

                  ],

                ),

              ),

              Icon(

                Iconsax.arrow_right_3,

                size: 18.r,

                color: colors.mutedText,

              ),

            ],

          ),

        ),

      ),

    );

  }



  Widget _fallback(FaithAppColors colors) {

    return ColoredBox(

      color: colors.tagBackground,

      child: Icon(Iconsax.people, color: colors.iconMuted, size: 24.r),

    );

  }

}


