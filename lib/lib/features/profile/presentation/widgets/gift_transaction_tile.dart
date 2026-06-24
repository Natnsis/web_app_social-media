import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/profile/domain/entities/gift_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftTransactionTile extends StatelessWidget {
  final GiftTransaction transaction;
  final bool showDivider;

  const GiftTransactionTile({
    super.key,
    required this.transaction,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: DarkTheme.feedTagBackground,
                child: Text(
                  transaction.donorInitials,
                  style: GoogleFonts.inter(
                    color: DarkTheme.feedMutedText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.donorName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${transaction.fundName} • ${formatShortTimeAgo(transaction.createdAt)}',
                      style: GoogleFonts.inter(
                        color: DarkTheme.feedMutedText,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrencyEtb(transaction.amount, showPlusSign: true),
                style: GoogleFonts.inter(
                  color: DarkTheme.greenSuccess500,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}
