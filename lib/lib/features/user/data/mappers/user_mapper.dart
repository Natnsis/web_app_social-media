import 'package:faithconnect/core/models/app_user_role.dart';
import 'package:faithconnect/core/models/user_entity.dart';
import 'package:faithconnect/core/utils/media_url_resolver.dart';
import 'package:faithconnect/features/user/data/dto/user_search_api_dto.dart';
import 'package:faithconnect/features/user/domain/entities/searched_user.dart';

abstract final class UserMapper {
  UserMapper._();

  static SearchedUser fromSearchDto(UserSearchApiDto dto) {
    return SearchedUser(
      id: dto.id,
      fullName: _displayName(dto.fullName),
      avatarUrl: MediaUrlResolver.normalize(dto.avatarUrl, imageOnly: true),
      phoneNumber: _optionalText(dto.phoneNumber),
    );
  }

  static String _displayName(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? 'User' : trimmed;
  }

  static String? _optionalText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static User fromMeApiMap(
    Map<String, dynamic> userMap, {
    User? stored,
  }) {
    final churchMap = userMap['church'] as Map<String, dynamic>?;
    final avatarRaw =
        userMap['avatarUrl']?.toString() ?? userMap['avatar']?.toString();
    final churchLogoRaw = churchMap?['logoUrl']?.toString();
    final apiRoles = AppUserRole.collectFromMap(userMap);
    final roles = apiRoles.isNotEmpty
        ? apiRoles
        : (stored?.roles ?? const <String>[]);

    return User(
      id: userMap['id']?.toString(),
      name: userMap['fullName']?.toString() ?? userMap['name']?.toString(),
      email: userMap['email']?.toString(),
      phone:
          userMap['phoneNumber']?.toString() ?? userMap['phone']?.toString(),
      avatar: MediaUrlResolver.normalize(avatarRaw, imageOnly: true),
      bio: _optionalText(userMap['bio']?.toString()),
      churchName: churchMap?['name']?.toString(),
      churchId: churchMap?['id']?.toString(),
      churchLogo: MediaUrlResolver.normalize(churchLogoRaw, imageOnly: true),
      roles: roles,
    );
  }
}
