import 'package:faithconnect/core/models/app_user_role.dart';

/// Cached user persisted in SharedPreferences (core layer DTO).
class User {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String? churchName;
  final String? churchId;
  final String? churchLogo;
  final List<String> roles;

  const User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.churchName,
    this.churchId,
    this.churchLogo,
    this.roles = const [],
  });

  bool get canManageChurchContent =>
      UserRoleCapabilities.canManageChurchContent(roles);

  factory User.fromJson(Map<String, dynamic> json) {
    final churchMap = json['church'] as Map<String, dynamic>?;
    return User(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      churchName: json['churchName'] as String? ?? churchMap?['name'] as String?,
      churchId: json['churchId'] as String? ?? churchMap?['id'] as String?,
      churchLogo: json['churchLogo'] as String? ?? churchMap?['logoUrl'] as String?,
      roles: AppUserRole.normalizeList(json['roles'] as List<dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'churchName': churchName,
      'churchId': churchId,
      'churchLogo': churchLogo,
      'roles': roles,
    };
  }
}