import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class NotificationsNavigation {
  NotificationsNavigation._();

  static void open(BuildContext context) {
    context.pushNamed(RoutesConstant.notifications);
  }
}
