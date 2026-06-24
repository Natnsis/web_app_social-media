import 'package:faithconnect/core/core.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';



/// Personal profile stats row (member view — no church / admin UI).

class MemberProfileSummary extends StatelessWidget {

  final int savedCount;

  final int likedCount;

  final int followingCount;



  const MemberProfileSummary({

    super.key,

    this.savedCount = 0,

    this.likedCount = 0,

    this.followingCount = 0,

  });



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;

    final isDark = context.isDarkMode;



    return Container(

      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),

      decoration: BoxDecoration(

        color: colors.cardBackground,

        borderRadius: BorderRadius.circular(16.r),

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

      child: Row(

        children: [

          _StatItem(label: 'Saved', value: savedCount),

          _divider(colors),

          _StatItem(label: 'Liked', value: likedCount),

          _divider(colors),

          _StatItem(label: 'Following', value: followingCount),

        ],

      ),

    );

  }



  Widget _divider(FaithAppColors colors) {

    return Container(

      width: 1,

      height: 28.h,

      color: colors.divider,

    );

  }

}



class _StatItem extends StatelessWidget {

  final String label;

  final int value;



  const _StatItem({required this.label, required this.value});



  @override

  Widget build(BuildContext context) {

    final colors = context.faithColors;



    return Expanded(

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Text(

            formatCount(value),

            style: GoogleFonts.inter(

              color: colors.primaryText,

              fontSize: 18.sp,

              fontWeight: FontWeight.w700,

            ),

          ),

          SizedBox(height: 4.h),

          Text(

            label,

            style: GoogleFonts.inter(

              color: colors.mutedText,

              fontSize: 12.sp,

              fontWeight: FontWeight.w500,

            ),

          ),

        ],

      ),

    );

  }

}


