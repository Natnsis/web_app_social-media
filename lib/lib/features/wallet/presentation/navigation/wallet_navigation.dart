import 'package:faithconnect/core/routes/routes_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WalletNavigation {
  static void openWallet(BuildContext context) {
    context.push(RoutesConstant.wallet);
  }
}
