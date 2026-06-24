import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class DiscoveryNavigation {
  DiscoveryNavigation._();

  static void openDiscovery(BuildContext context) {
    context.pushNamed(RoutesConstant.discovery);
  }

  static void openNearby(BuildContext context) {
    context.pushNamed(RoutesConstant.discoveryNearby);
  }
}
