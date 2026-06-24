import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/home/domain/home_shell_account_mode.dart';
import 'package:flutter/foundation.dart';

/// Church vs user mode for the home shell (drawer + FAB).
class HomeShellModeNotifier extends ChangeNotifier {
  HomeShellAccountMode _mode = HomeShellAccountMode.user;
  List<String> _roles = const [];

  HomeShellAccountMode get mode => _mode;

  List<String> get roles => List.unmodifiable(_roles);

  bool get isChurchMode => _mode.isChurch;

  bool get canManageChurchContent =>
      UserRoleCapabilities.canManageChurchContent(_roles);

  bool get canSwitchAccountMode => canManageChurchContent;

  /// Elevated roles (e.g. USER + CHURCH_OWNER) always retain create/admin access,
  /// even when browsing in community member view mode.
  bool get showCreateActions => canManageChurchContent;

  String get roleLabel => UserRoleCapabilities.primaryRoleLabel(_roles);

  Future<void> load() async {
    final user = await SharedPrefsService.getUser();
    _roles = user?.roles ?? const [];
    await _applyStoredMode();
    notifyListeners();
  }

  Future<void> applyUserRoles(List<String> roles) async {
    _roles = AppUserRole.normalizeList(roles);
    if (!canManageChurchContent) {
      await setMode(HomeShellAccountMode.user);
      return;
    }
    await _applyStoredMode();
    notifyListeners();
  }

  Future<void> _applyStoredMode() async {
    if (!canManageChurchContent) {
      _mode = HomeShellAccountMode.user;
      await SharedPrefsService.setAccountViewMode(_mode.name);
      return;
    }

    // `USER` + `CHURCH_OWNER` (or any elevated role) → full church-admin UI.
    _mode = HomeShellAccountMode.church;
    await SharedPrefsService.setAccountViewMode(_mode.name);
  }

  Future<void> setMode(HomeShellAccountMode mode) async {
    if (!canManageChurchContent) {
      mode = HomeShellAccountMode.user;
    }
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await SharedPrefsService.setAccountViewMode(mode.name);
  }
}
