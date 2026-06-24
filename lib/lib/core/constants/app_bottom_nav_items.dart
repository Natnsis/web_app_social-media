import 'package:faithconnect/core/widgets/bottom_nav.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Default main-app tabs for [BottomNav] / [AppShellLayout].
abstract final class AppBottomNavItems {
  AppBottomNavItems._();

  static const BottomNavItem home = BottomNavItem(
    id: 'home',
    icon: Iconsax.home_2,
    activeIcon: Iconsax.home_2_copy,
    label: 'Home',
  );

  static const BottomNavItem chats = BottomNavItem(
    id: 'chats',
    icon: Iconsax.message,
    activeIcon: Iconsax.message_copy,
    label: 'Chats',
  );

  static const BottomNavItem shorts = BottomNavItem(
    id: 'shorts',
    icon: Iconsax.play_circle,
    activeIcon: Iconsax.play_circle_copy,
    label: 'Shorts',
  );

  static const BottomNavItem account = BottomNavItem(
    id: 'account',
    icon: Iconsax.user,
    activeIcon: Iconsax.user_copy,
    label: 'Account',
  );

  static const List<BottomNavItem> main = [
    home,
    chats,
    shorts,
    account,
  ];

  static int indexOf(String id) => main.indexWhere((item) => item.id == id);
}
