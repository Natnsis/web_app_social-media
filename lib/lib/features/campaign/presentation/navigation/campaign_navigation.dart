import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central entry points for the campaign user journey (hub → create → detail).
abstract final class CampaignNavigation {
  CampaignNavigation._();

  static void openHub(
    BuildContext context, {
    bool openCreate = false,
  }) {
    context.pushNamed(
      RoutesConstant.campaigns,
      queryParameters: openCreate ? const {'create': '1'} : const {},
    );
  }

  static Future<String?> openCreate(BuildContext context) {
    return context.pushNamed<String>(RoutesConstant.newCampaign);
  }

  static void openDetail(
    BuildContext context,
    String campaignId, {
    bool donate = false,
  }) {
    context.pushNamed(
      RoutesConstant.campaignDetail,
      pathParameters: {'id': campaignId},
      queryParameters: donate ? {'donate': '1'} : const {},
    );
  }
}
