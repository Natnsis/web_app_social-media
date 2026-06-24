import 'package:faithconnect/core/models/app_user_role.dart';
import 'package:faithconnect/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.avatarUrl,
    super.roles = const [],
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    List<String> roles = const [],
  }) {
    final parsedRoles = roles.isNotEmpty
        ? roles
        : AppUserRole.collectFromMap(json);

    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? json['fullName'] as String?,
      phone: json['phone'] as String? ?? json['phoneNumber'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      roles: parsedRoles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'roles': roles,
    };
  }

  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
        roles: roles,
      );
}
