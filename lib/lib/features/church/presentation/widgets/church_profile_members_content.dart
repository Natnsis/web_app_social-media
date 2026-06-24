import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/chat/presentation/navigation/chat_navigation.dart';
import 'package:faithconnect/features/church/domain/entities/church_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ChurchProfileMembersContent {
  ChurchProfileMembersContent._();

  static List<Widget> buildSlivers(List<ChurchMember> members) {
    final owner = members.where((m) => m.role?.toLowerCase() == 'owner').firstOrNull;
    final rest = members.where((m) => m.role?.toLowerCase() != 'owner').toList();

    return [
      // ── Owner card (if present) ──────────────────────────────────────
      if (owner != null)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          sliver: SliverToBoxAdapter(
            child: _OwnerCard(owner: owner),
          ),
        ),

      // ── Regular members list ─────────────────────────────────────────
      if (rest.isNotEmpty)
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList.separated(
            itemCount: rest.length,
            separatorBuilder: (_, _) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              return _MemberTile(member: rest[index]);
            },
          ),
        ),
    ];
  }
}

// ─── Owner Card ────────────────────────────────────────────────────────────────

class _OwnerCard extends StatelessWidget {
  final ChurchMember owner;

  const _OwnerCard({required this.owner});

  Future<void> _openChat(BuildContext context) {
    return ChatNavigation.openDirectChat(
      context: context,
      userId: owner.userId,
      displayName: owner.name,
      avatarUrl: owner.avatarUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return GestureDetector(
      onTap: () => _openChat(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              colors.brandSky.withValues(alpha: 0.15),
              colors.brandBlue.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: colors.brandSky.withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          children: [
            // Avatar with glowing ring
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.brandSky, colors.brandBlue],
                ),
              ),
              child: AppAvatar(
                imageUrl: owner.avatarUrl,
                initials: AppAvatar.initialsFromName(owner.name),
                size: 48,
              ),
            ),

            // ── Gap between avatar and text ──────────────────────────
            SizedBox(width: 14.w),

            // Name
            Expanded(
              child: Text(
                owner.name,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(width: 8.w),

            // Role badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.brandSky.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.profile_circle,
                    size: 12.r,
                    color: colors.brandSky,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    owner.role ?? 'Owner',
                    style: GoogleFonts.inter(
                      color: colors.brandSky,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Regular Member Tile ───────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  final ChurchMember member;

  const _MemberTile({required this.member});

  Future<void> _openChat(BuildContext context) {
    return ChatNavigation.openDirectChat(
      context: context,
      userId: member.userId,
      displayName: member.name,
      avatarUrl: member.avatarUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    final isOwner = member.role?.toLowerCase() == 'owner';

    return AppCompactCard(
      onTap: () => _openChat(context),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: member.avatarUrl,
            initials: AppAvatar.initialsFromName(member.name),
            size: 44,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.role != null && member.role!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    member.role!,
                    style: GoogleFonts.inter(
                      color: colors.mutedText,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            isOwner ? Iconsax.profile_circle : Iconsax.shield_tick,
            color: isOwner ? colors.brandSky : colors.brandBlue,
            size: 20.r,
          ),
        ],
      ),
    );
  }
}
