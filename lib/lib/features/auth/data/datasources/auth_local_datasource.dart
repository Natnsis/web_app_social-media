import 'package:faithconnect/core/models/user_entity.dart' as core;
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:faithconnect/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> cacheUser(UserModel user) async {
    await SharedPrefsService.saveUser(
      core.User(
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        avatar: user.avatarUrl,
        roles: user.roles,
      ),
    );
    await SharedPrefsService.setLoggedIn(true);
    await SharedPrefsService.saveUserId(user.id);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final user = await SharedPrefsService.getUser();
    if (user == null) return null;
    return UserModel(
      id: user.id ?? '',
      email: user.email ?? '',
      name: user.name,
      phone: user.phone,
      avatarUrl: user.avatar,
      roles: user.roles,
    );
  }

  @override
  Future<void> clearSession() async {
    await SharedPrefsService.logout();
  }
}
