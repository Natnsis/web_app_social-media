import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:faithconnect/features/home/gift/presentation/widgets/live_gift_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class GiftNavigation {
  GiftNavigation._();

  static void openGift(BuildContext context) {
    context.pushNamed(RoutesConstant.gift);
  }

  static Future<void> openLiveGiftSheet(
    BuildContext context, {
    required String streamId,
    required String hostName,
  }) {
    return LiveGiftBottomSheet.show(
      context,
      streamId: streamId,
      hostName: hostName,
    );
  }
}
