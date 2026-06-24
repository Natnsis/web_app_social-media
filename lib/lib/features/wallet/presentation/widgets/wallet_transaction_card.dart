import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class WalletTransactionCard extends StatelessWidget {
  final WalletTransactionType type;
  final String title;
  final String? subtitle;
  final String amount;
  final String status;
  final String dateString;
  final String? iconUrl;

  const WalletTransactionCard({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.status,
    required this.dateString,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isDark = context.isDarkMode;
    final statusStyle = _statusStyle(context, status);

    final iconBackground = type == WalletTransactionType.campaignDonation
        ? colors.brandBlue.withValues(alpha: 0.14)
        : const Color(0xFFE91E63).withValues(alpha: 0.14);
    final iconTint = type == WalletTransactionType.campaignDonation
        ? colors.brandBlue
        : const Color(0xFFE91E63);

    return AppCompactCard(
      borderRadius: 20,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      backgroundColor: colors.cardBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : colors.divider,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: iconUrl != null && iconUrl!.isNotEmpty
                ? Image.network(
                    iconUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _TypeIcon(
                      type: type,
                      color: iconTint,
                    ),
                  )
                : _TypeIcon(type: type, color: iconTint),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                ],
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(statusStyle.icon, color: statusStyle.color, size: 14.r),
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: GoogleFonts.inter(
                        color: statusStyle.color,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                dateString,
                style: GoogleFonts.inter(
                  color: colors.mutedText,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(BuildContext context, String rawStatus) {
    final colors = context.faithColors;
    switch (rawStatus.toUpperCase()) {
      case 'SUCCESS':
      case 'COMPLETED':
        return _StatusStyle(
          color: context.success,
          icon: Iconsax.tick_circle,
        );
      case 'PENDING':
        return _StatusStyle(
          color: context.warning,
          icon: Iconsax.clock,
        );
      case 'FAILED':
        return _StatusStyle(
          color: colors.error,
          icon: Iconsax.close_circle,
        );
      default:
        return _StatusStyle(
          color: colors.mutedText,
          icon: Iconsax.info_circle,
        );
    }
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;

  const _StatusStyle({required this.color, required this.icon});
}

class _TypeIcon extends StatelessWidget {
  final WalletTransactionType type;
  final Color color;

  const _TypeIcon({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        type == WalletTransactionType.campaignDonation
            ? Iconsax.flag
            : Iconsax.gift,
        color: color,
        size: 20.r,
      ),
    );
  }
}
