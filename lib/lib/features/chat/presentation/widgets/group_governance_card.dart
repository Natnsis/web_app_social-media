import 'package:faithconnect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupGovernanceCard extends StatelessWidget {
  final bool isPrivate;
  final bool allowMemberInvitations;
  final ValueChanged<bool> onPrivateChanged;
  final ValueChanged<bool> onInvitationsChanged;

  const GroupGovernanceCard({
    super.key,
    required this.isPrivate,
    required this.allowMemberInvitations,
    required this.onPrivateChanged,
    required this.onInvitationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return AppSurfaceCard(
      borderRadius: 20,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
            child: Text(
              'Governance & Privacy',
              style: GoogleFonts.inter(
                color: colors.brandBlue,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSettingsSwitchTile(
            title: 'Private Group',
            subtitle:
                'Only members can see posts and participant list.',
            value: isPrivate,
            onChanged: onPrivateChanged,
          ),
          AppSettingsSwitchTile(
            title: 'Allow Member Invitations',
            subtitle:
                'Existing members can invite their contacts to join.',
            value: allowMemberInvitations,
            onChanged: onInvitationsChanged,
          ),
        ],
      ),
    );
  }
}
