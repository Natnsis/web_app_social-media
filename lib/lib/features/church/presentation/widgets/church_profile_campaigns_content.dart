import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign.dart';
import 'package:faithconnect/features/campaign/presentation/widgets/campaign_compact_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChurchProfileCampaignsContent {
  ChurchProfileCampaignsContent._();

  static List<Widget> buildSlivers(List<Campaign> campaigns) {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList.separated(
          itemCount: campaigns.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return CampaignCompactCard(
              campaign: campaign,
              onTap: () => context.pushNamed(
                RoutesConstant.campaignDetail,
                pathParameters: {'id': campaign.id},
              ),
            );
          },
        ),
      ),
    ];
  }
}
